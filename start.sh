sudo su

apt update

## https://kr.godaddy.com/help/add-memory-swap-ubuntu-or-debian-7-17326
fallocate -l 4G /swapfile
ls -lh /swapfile
chmod 600 /swapfile
ls -lh /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s

apt install -y git libcurl4-openssl-dev libssl-dev libxml2-dev libatlas3-base
apt install -y r-base r-base-dev

# how to use screen
# http://www.incodom.kr/Linux/%EA%B8%B0%EB%B3%B8%EB%AA%85%EB%A0%B9%EC%96%B4/screen

screen

git clone https://github.com/mrchypark/wthr_chatr
cd wthr_chatr
Rscript app.R