#!/bin/bash

#에러 발생시 중지
set -e

#jupyterhub와 라이브러리 설치
echo "Jupyterhub와 라이브러리 설치 중~" 
dnf install -y python3-pip npm 
npm install -g configurable-http-proxy
pip install --no-input jupyterhub jupyterlab notebook

#jupyterhub 설정 파일 생성 및 편집
echo "Jupyterhub 설정 파일 생성 중~"
jupyterhub --generate-config
mkdir /etc/jupyterhub
mv jupyterhub_config.py /etc/jupyterhub

#jupyterHub 셋업 
echo "c.Authenticator.allow_all = True" >>  /etc/jupyterhub/jupyterhub_config.pyecho "c.JupyterHub.ip = ''" >> /etc/jupyterhub/jupyterhub_config.py

#방화벽 제어 
echo "방화벽 설정 중~"
firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --reload
echo "방화벽 적용 완료~" 

#JupyterHub 라는 서비스 만들기 
cat << EOF > /etc/systemd/system/jupyterhub.service
[Unit]
Description=JupyterHub service
After=syslog.target network.target
[Service]
User=root
Type=simple
WorkingDirectory=/etc/jupyterhub
ExecStart=/usr/local/bin/jupyterhub --config=jupyterhub_config.py
ExecStop=/usr/bin/pkill -f jupyterhub
Restart=always
TimeoutStartSec=60
RestartSec=60
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=jupyterhub
[Install]
WantedBy=multi-user.target network-online.target
EOF


echo "JupyterHub 서비스 설정 완료"


#JupyterHub 서비스 셋업 
echo "JupyterHub 서비스 셋업 중"
systemctl daemon-reload
systemctl enable jupyterhub
systemctl start jupyterhub

echo "JupyterHub 서비스 설치 완료! 상태 확인하겠습니다"
systemctl status jupyterhub



#프로그램 설치하는 명령어 
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/eunigo/setup-Jupyter/refs/heads/main/setupJupyterHub.sh)"


