source common.sh

print_head "Installing Nginx"
yum install nginx -y &>>${log_file}
status_check $?

print_head "Removing Old Content"
rm -rf /usr/share/nginx/html/* &>>${log_file}
status_check $?

print_head "Downloading Frontend Content"
curl -L -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
status_check $?

cd /usr/share/nginx/html

print_head "Extracting Downloaded Frontend"
unzip /tmp/frontend.zip &>>${log_file}
status_check $?

print_head "Copying Nginx Config for RoboShop"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
status_check $?

print_head "Enabling Nginx"
systemctl enable nginx &>>${log_file}
status_check $?

print_head "Starting Nginx"
systemctl start nginx
status_check $?