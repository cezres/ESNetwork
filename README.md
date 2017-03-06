# ESNetwork

```
source 'https://github.com/cezres/PrivatePods.git'
pod 'ESNetwork'
```


- **ESRequestHandler** 请求处理。调用AFNetWorking，处理内置请求参数/请求头、动态拼接URLStirng内的参数。 
- **ESRequestCache** 请求缓存。 存储、读取、清除缓存。 根据组、标识，以文件方式存储。 
- **ESRequest** 请求主体对象。更方便的配置请求、缓存参数以及做一些公共的处理，缓存、执行各个阶段的回调。 
- **ESBaseRequest** 继承自ESRequest，请求基类。 根据项目封装一些接口：更方便的加载分页数据、获取返回数据的请求状态和错误信息、Loading提示、请求错误提示、无数据提示...