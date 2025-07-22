# 使用Debian作为基础镜像
FROM debian:bullseye

# 避免在安装过程中出现交互式提示
ARG DEBIAN_FRONTEND=noninteractive

# 更新软件包列表并安装基本工具
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    openssh-client \
    openssh-server \
    vim \
    wget \
    build-essential \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    # Python 3.10 依赖
    lzma \
    liblzma-dev \
    libreadline-dev \
    # 清理apt缓存以减小镜像大小
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装Python 3.10
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz \
    && tar -xf Python-3.10.0.tgz \
    && cd Python-3.10.0 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.10.0 Python-3.10.0.tgz

# 创建Python 3.10的软链接
RUN ln -sf /usr/local/bin/python3.10 /usr/local/bin/python3 \
    && ln -sf /usr/local/bin/python3.10 /usr/local/bin/python \
    && ln -sf /usr/local/bin/pip3.10 /usr/local/bin/pip3 \
    && ln -sf /usr/local/bin/pip3.10 /usr/local/bin/pip

# 升级pip
RUN pip3 install --upgrade pip

# 配置SSH服务
RUN mkdir -p /var/run/sshd

# 设置root用户密码为123456
RUN echo 'root:123456' | chpasswd

# 允许root用户通过SSH登录
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH登录时需要密码认证
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 设置工作目录
WORKDIR /app

# 暴露SSH端口
EXPOSE 22

# 启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]