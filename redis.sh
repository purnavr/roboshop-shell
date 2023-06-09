source common.sh

print_head "Setup redis repository"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
status_check $?

print_head "enable redis from 6.2 package"
yum module enable redis:remi-6.2 -y &>>${log_file}
status_check $?

print_head "Installing redis"
yum install redis -y  &>>${log_file}
status_check $?

print_head "Update redis Listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>${log_file}
status_check $?

print_head "Enable redis"
systemctl enable redis &>>${log_file}
status_check $?

print_head "Starting redis"
systemctl start redis &>>${log_file}
status_check $?