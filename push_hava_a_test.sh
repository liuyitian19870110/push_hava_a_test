#!/bin/bash

if [ -z "$SHOGUNCAO_HAVA_A_TEST_SSH_KEY" ]; then
    echo "必须设置 SHOGUNCAO_HAVA_A_TEST_SSH_KEY"
    exit 1
fi
if [ -z "$TARGET_HAVA_A_TEST_SSH_KEY" ]; then
    echo "必须设置 TARGET_HAVA_A_TEST_SSH_KEY"
    exit 1
fi
if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
    echo "必须设置 GITHUB_REPOSITORY_OWNER"
    exit 1
fi

# 创建ssh的相关配置
mkdir -p "$HOME/.ssh/config.d"
if [ ! -f "$HOME/.ssh/config" ]; then
    touch "$HOME/.ssh/config"
fi
if ! grep -q "Include config.d/\*.conf" "$HOME/.ssh/config"; then
    {
        printf "Include config.d/*.conf\n\n"
        cat "$HOME/.ssh/config"
    } > "$HOME/.ssh/config.tmp" && mv "$HOME/.ssh/config.tmp" "$HOME/.ssh/config"
fi
chmod 700 "$HOME/.ssh"
chmod 700 "$HOME/.ssh/config.d"

# 写入hava_a_test的密钥
rm -rf "$HOME/.ssh/config.d/hava_a_test"
echo "${SHOGUNCAO_HAVA_A_TEST_SSH_KEY}" > "$HOME/.ssh/config.d/hava_a_test"
chmod 600 "$HOME/.ssh/config.d/hava_a_test"

# 创建$HOME/.ssh/config.d/hava_a_test.conf
rm -rf "$HOME/.ssh/config.d/hava_a_test.conf"
cat > "$HOME/.ssh/config.d/hava_a_test.conf" << EOF
Host github.com-hava_a_test
    HostName github.com
    IdentityFile ~/.ssh/config.d/hava_a_test
EOF

# 写入TARGET_HAVA_A_TEST_SSH_KEY密钥
rm -rf "$HOME/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}"
echo "${TARGET_HAVA_A_TEST_SSH_KEY}" > "$HOME/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}"
chmod 600 "$HOME/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}"

# 创建$HOME/.ssh/config.d/TARGET_HAVA_A_TEST_SSH_KEY.conf
rm -rf "$HOME/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}.conf"
cat > "$HOME/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}.conf" << EOF
Host github.com-${GITHUB_REPOSITORY_OWNER}
    HostName github.com
    IdentityFile ~/.ssh/config.d/${GITHUB_REPOSITORY_OWNER}
EOF

# 拉取hava_a_test原始项目
rm -rf hava_a_test
git clone git@github.com-hava_a_test:shoguncao/hava_a_test.git

# 调用hava_a_test/push_repo.sh
pushd hava_a_test
/bin/bash push_repo.sh --account_id ${GITHUB_REPOSITORY_OWNER}
popd
