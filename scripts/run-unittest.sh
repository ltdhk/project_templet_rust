if [ "$1" = "dev" ]; then

 # 运行开发环境下的单元测试，排除所有名字带integration的集成测试
 cargo nextest run  --workspace --exclude-regex "integration"

else

  # 运行开发环境下的单元测试（ci profile），排除所有名字带integration的集成测试
 cargo nextest run  --profile=ci --workspace --exclude-regex "integration"

fi
