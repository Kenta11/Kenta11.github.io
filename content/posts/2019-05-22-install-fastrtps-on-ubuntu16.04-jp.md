---
title: Ubuntu 16.04にFast-RTPSをインストールする
date: 2019-05-22 19:00:00 +0900
tags: [Fast-RTPS]
toc: true
---

## はじめに

Ubuntu 16.04 LTSにFast-RTPSをインストールする．
fastrtpsgenも一緒にインストールしたいので，自分の環境にインストールしてみる．

## cmakeする

[Fast RTPS Installation](https://dev.px4.io/en/setup/fast-rtps-installation.html)によると，cmakeとmakeでFast-RTPSとfastrtpsgenをビルドするようだ．
cmakeを実行すると，以下のログが表示された．

```shell
$ git clone https://github.com/eProsima/Fast-RTPS
$ cd Fast-RTPS
$ mkdir build; cd build
$ cmake -DTHIRDPARTY=ON -DBUILD_JAVA=ON ..
-- Setting build type to 'Release' as none was specified.

(中略)

CMake Error at /usr/share/cmake-3.5/Modules/FindPackageHandleStandardArgs.cmake:148 (message):
  Could NOT find Java (missing: Java_JAVA_EXECUTABLE Runtime) (Required is at
  least version "1.6")
Call Stack (most recent call first):
  /usr/share/cmake-3.5/Modules/FindPackageHandleStandardArgs.cmake:388 (_FPHSA_FAILURE_MESSAGE)
  /usr/share/cmake-3.5/Modules/FindJava.cmake:244 (find_package_handle_standard_args)
  cmake/dev/java_support.cmake:16 (find_package)
  CMakeLists.txt:263 (gradle_build)


-- Configuring incomplete, errors occurred!
See also "/home/kenta/git/Fast-RTPS/build/CMakeFiles/CMakeOutput.log".
See also "/home/kenta/git/Fast-RTPS/build/CMakeFiles/CMakeError.log".
```

Javaが無いと言われた．
ドキュメントには`Java is required to use our built-in code generation tool - fastrtpsgen. Java JDK 8 is recommended.`とあるので，openjdkのバージョン8をインストールする．

```shell
$ sudo apt install openjdk-8-jdk
$ rm -rf *
$ cmake -DTHIRDPARTY=ON -DBUILD_JAVA=ON ..
-- Configuring Fast RTPS
-- Version: 1.8.0
-- To change the version modify the file configure.ac
-- fastcdr thirdparty is being updated...
-- Configuring Fast CDR
-- Version: 1.0.9
-- To change the version modify the file configure.ac
-- fastcdr library found...
-- Found Java: /usr/bin/java (found suitable version "1.8.0.212", minimum required is "1.6") found components:  Runtime 
CMake Error at cmake/dev/java_support.cmake:30 (message):
  gradle is needed to build the java application.  Please install it
  correctly
Call Stack (most recent call first):
  CMakeLists.txt:263 (gradle_build)


-- Configuring incomplete, errors occurred!
See also "/home/kenta/git/Fast-RTPS/build/CMakeFiles/CMakeOutput.log".
See also "/home/kenta/git/Fast-RTPS/build/CMakeFiles/CMakeError.log".
```

今度はgradleが必要だと言われた．インストールし，再度ビルドする．

```shell
$ sudo apt install gradle
$ rm -rf *
$ cmake -DTHIRDPARTY=ON -DBUILD_JAVA=ON .. # エラーなく終了！
```

## ビルドしてインストールする

```shell
$ make -j8 # エラーなく終了！
$ sudo checkinstall

checkinstall 1.6.2, Copyright 2009 Felipe Eduardo Sanchez Diaz Duran
           このソフトウェアはGNU GPLの下でリリースしています。


The package documentation directory ./doc-pak does not exist. 
Should I create a default set of package docs?  [y]: y

パッケージのドキュメンテーションを準備..OK

*** No known documentation files were found. The new package 
*** won't include a documentation directory.

このパッケージの説明を書いてください
説明の末尾は空行かEOFにしてください。
>> Fast-RTPS and fastrtpsgen
>> 

*****************************************
**** Debian package creation selected ***
*****************************************

(中略)

このパッケージは以下の内容で構成されます: 

0 -  Maintainer: [ kenta@xxxx ]
1 -  Summary: [ Fast-RTPS and fastrtpsgen ]
2 -  Name:    [ fastrtps ]
3 -  Version: [ 20190522 ]
4 -  Release: [ 1 ]
5 -  License: [ GPL ]
6 -  Group:   [ checkinstall ]
7 -  Architecture: [ amd64 ]
8 -  Source location: [ build ]
9 -  Alternate source location: [  ]
10 - Requires: [  ]
11 - Provides: [ build ]
12 - Conflicts: [  ]
13 - Replaces: [  ]

変更するものの番号を入力してください。Enterで続行します: 

Installing with make install...
========================= インストールの結果 ===========================
[  1%] Updating Git module idl
[  1%] Built target git_submodule_update_idl
[  2%] Updating Git module fastcdr
[  2%] Built target git_submodule_update_fastcdr
[  3%] Generating Java application

FAILURE: Build failed with an exception.

* Where:
Build file '/home/kenta/git/Fast-RTPS/fastrtpsgen/build.gradle' line: 78

* What went wrong:
Could not resolve all dependencies for configuration ':compile'.
> Could not resolve junit:junit:4.+.
  Required by:
      :fastrtpsgen:unspecified
   > Could not resolve junit:junit:4.+.
      > Failed to list versions for junit:junit.
         > Unable to load Maven meta-data from https://repo1.maven.org/maven2/junit/junit/maven-metadata.xml.
            > Could not GET 'https://repo1.maven.org/maven2/junit/junit/maven-metadata.xml'.
               > 接続がタイムアウトしました (Connection timed out)

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 2 mins 8.884 secs
CMakeFiles/java.dir/build.make:57: ターゲット 'CMakeFiles/java' のレシピで失敗しました
make[2]: *** [CMakeFiles/java] エラー 1
CMakeFiles/Makefile2:356: ターゲット 'CMakeFiles/java.dir/all' のレシピで失敗しました
make[1]: *** [CMakeFiles/java.dir/all] エラー 2
Makefile:160: ターゲット 'all' のレシピで失敗しました
make: *** [all] エラー 2

****  インストールは失敗しました。パッケージの作成を中断します

上書きしたファイルをバックアップから復元..OK

クリーンアップ..OK

Bye.
```

接続がタイムアウトしたと表示されており，インストールが完了しない．
プロキシ環境にあるこのマシンでは，どうも`sudo checkinstall`の中で実行されるgradleがコケるようだ．

そこでrootにgradleのプロキシ設定を反映させて，インストールをする．

```shell
$ sudo cp ~/.gradle/gradle.properties /root/.gradle/ # 自分のgradleの設定をrootにも反映
$ sudo checkinstall

checkinstall 1.6.2, Copyright 2009 Felipe Eduardo Sanchez Diaz Duran
           このソフトウェアはGNU GPLの下でリリースしています。


The package documentation directory ./doc-pak does not exist. 
Should I create a default set of package docs?  [y]: 

パッケージのドキュメンテーションを準備..OK

*** No known documentation files were found. The new package 
*** won't include a documentation directory.

*****************************************
**** Debian package creation selected ***
*****************************************
(中略)

このパッケージは以下の内容で構成されます: 

0 -  Maintainer: [ kenta@xxxxx ]
1 -  Summary: [ Fast-RTPS and fastrtpsgen ]
2 -  Name:    [ fastrtps ]
3 -  Version: [ 20190522 ]
4 -  Release: [ 1 ]
5 -  License: [ GPL ]
6 -  Group:   [ checkinstall ]
7 -  Architecture: [ amd64 ]
8 -  Source location: [ build ]
9 -  Alternate source location: [  ]
10 - Requires: [  ]
11 - Provides: [ build ]
12 - Conflicts: [  ]
13 - Replaces: [  ]

変更するものの番号を入力してください。Enterで続行します: 

Installing with make install...

========================= インストールの結果 ===========================
[  1%] Updating Git module idl
[  1%] Built target git_submodule_update_idl
[  2%] Updating Git module fastcdr
[  2%] Built target git_submodule_update_fastcdr
[  3%] Generating Java application
:buildIDLParser
Download https://plugins.gradle.org/m2/me/champeau/gradle/antlr4-gradle-plugin/0.1/antlr4-gradle-plugin-0.1.pom
Download https://plugins.gradle.org/m2/me/champeau/gradle/antlr4-gradle-plugin/0.1/antlr4-gradle-plugin-0.1.jar
Download https://repo1.maven.org/maven2/org/antlr/antlr4/4.2.2/antlr4-4.2.2.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr4-master/4.2.2/antlr4-master-4.2.2.pom
Download https://repo1.maven.org/maven2/org/sonatype/oss/oss-parent/7/oss-parent-7.pom
Download https://repo1.maven.org/maven2/org/antlr/stringtemplate/3.2/stringtemplate-3.2.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr4-runtime/4.2.2/antlr4-runtime-4.2.2.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr4-annotations/4.2.2/antlr4-annotations-4.2.2.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr-runtime/3.5.2/antlr-runtime-3.5.2.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr-master/3.5.2/antlr-master-3.5.2.pom
Download https://repo1.maven.org/maven2/org/sonatype/oss/oss-parent/9/oss-parent-9.pom
Download https://repo1.maven.org/maven2/org/antlr/ST4/4.0.8/ST4-4.0.8.pom
Download https://repo1.maven.org/maven2/antlr/antlr/2.7.7/antlr-2.7.7.pom
Download https://repo1.maven.org/maven2/org/abego/treelayout/org.abego.treelayout.core/1.0.1/org.abego.treelayout.core-1.0.1.pom
Download https://repo1.maven.org/maven2/org/antlr/antlr4/4.2.2/antlr4-4.2.2.jar
Download https://repo1.maven.org/maven2/org/antlr/stringtemplate/3.2/stringtemplate-3.2.jar
Download https://repo1.maven.org/maven2/org/antlr/antlr4-runtime/4.2.2/antlr4-runtime-4.2.2.jar
Download https://repo1.maven.org/maven2/org/antlr/antlr4-annotations/4.2.2/antlr4-annotations-4.2.2.jar
Download https://repo1.maven.org/maven2/org/antlr/antlr-runtime/3.5.2/antlr-runtime-3.5.2.jar
Download https://repo1.maven.org/maven2/org/antlr/ST4/4.0.8/ST4-4.0.8.jar
Download https://repo1.maven.org/maven2/antlr/antlr/2.7.7/antlr-2.7.7.jar
Download https://repo1.maven.org/maven2/org/abego/treelayout/org.abego.treelayout.core/1.0.1/org.abego.treelayout.core-1.0.1.jar
:idl:clean
:idl:antlr4
:idl:compileJava
警告: [options] ブートストラップ・クラスパスが-source 1.6と一緒に設定されていません
注意:/home/kenta/git/Fast-RTPS/thirdparty/idl/src/main/java/com/eprosima/idl/generator/manager/TemplateUtil.javaの操作は、未チェックまたは安全ではありません。
注意:詳細は、-Xlint:uncheckedオプションを指定して再コンパイルしてください。
:idl:processResources
:idl:classes
:idl:jar
:idl:assemble
:idl:compileTestJava UP-TO-DATE
:idl:processTestResources UP-TO-DATE
:idl:testClasses UP-TO-DATE
:idl:test UP-TO-DATE
:idl:check UP-TO-DATE
:idl:build
:compileJava
警告: [options] ブートストラップ・クラスパスが-source 1.6と一緒に設定されていません
注意:入力ファイルの操作のうち、未チェックまたは安全ではないものがあります。
注意:詳細は、-Xlint:uncheckedオプションを指定して再コンパイルしてください。
:processResources UP-TO-DATE
:classes
:jar
:assemble
:compileTestJava UP-TO-DATE
:processTestResources UP-TO-DATE
:testClasses UP-TO-DATE
:test UP-TO-DATE
:check UP-TO-DATE
:build

BUILD SUCCESSFUL

Total time: 11.629 secs

This build could be faster, please consider using the Gradle Daemon: https://docs.gradle.org/2.10/userguide/gradle_daemon.html
[  3%] Built target java
[  8%] Built target fastcdr
[100%] Built target fastrtps
Install the project...
-- Install configuration: "Release"
-- Installing: /usr/local/share/fastrtps/LICENSE
-- Installing: /usr/local/share/fastrtps/fastrtpsgen.jar
-- Installing: /usr/local/bin/fastrtpsgen
-- Installing: /usr/local/share/fastrtps/LICENSE
-- Installing: /usr/local/include/fastcdr
-- Installing: /usr/local/include/fastcdr/exceptions
-- Installing: /usr/local/include/fastcdr/exceptions/NotEnoughMemoryException.h
-- Installing: /usr/local/include/fastcdr/exceptions/Exception.h
-- Installing: /usr/local/include/fastcdr/exceptions/BadParamException.h
-- Installing: /usr/local/include/fastcdr/FastBuffer.h
-- Installing: /usr/local/include/fastcdr/FastCdr.h
-- Installing: /usr/local/include/fastcdr/fastcdr_dll.h
-- Installing: /usr/local/include/fastcdr/eProsima_auto_link.h
-- Installing: /usr/local/include/fastcdr/Cdr.h
-- Installing: /usr/local/include/fastcdr/config.h
-- Installing: /usr/local/lib/libfastcdr.so.1.0.8
-- Installing: /usr/local/lib/libfastcdr.so.1
-- Installing: /usr/local/lib/libfastcdr.so
-- Installing: /usr/local/share/fastcdr/cmake/fastcdr-targets.cmake
-- Installing: /usr/local/share/fastcdr/cmake/fastcdr-targets-release.cmake
-- Installing: /usr/local/share/fastcdr/cmake/fastcdr-config.cmake
-- Installing: /usr/local/share/fastcdr/cmake/fastcdr-config-version.cmake
-- Installing: /usr/local/include/fastrtps
-- Installing: /usr/local/include/fastrtps/xmlparser
-- Installing: /usr/local/include/fastrtps/xmlparser/XMLEndpointParser.h
-- Installing: /usr/local/include/fastrtps/xmlparser/XMLParser.h
-- Installing: /usr/local/include/fastrtps/xmlparser/XMLProfileManager.h
-- Installing: /usr/local/include/fastrtps/xmlparser/XMLTree.h
-- Installing: /usr/local/include/fastrtps/xmlparser/XMLParserCommon.h
-- Installing: /usr/local/include/fastrtps/qos
-- Installing: /usr/local/include/fastrtps/qos/ParameterList.h
-- Installing: /usr/local/include/fastrtps/qos/WriterQos.h
-- Installing: /usr/local/include/fastrtps/qos/ReaderQos.h
-- Installing: /usr/local/include/fastrtps/qos/ParameterTypes.h
-- Installing: /usr/local/include/fastrtps/qos/QosPolicies.h
-- Installing: /usr/local/include/fastrtps/log
-- Installing: /usr/local/include/fastrtps/log/Colors.h
-- Installing: /usr/local/include/fastrtps/log/StdoutConsumer.h
-- Installing: /usr/local/include/fastrtps/log/Log.h
-- Installing: /usr/local/include/fastrtps/fastrtps_dll.h
-- Installing: /usr/local/include/fastrtps/subscriber
-- Installing: /usr/local/include/fastrtps/subscriber/SubscriberHistory.h
-- Installing: /usr/local/include/fastrtps/subscriber/Subscriber.h
-- Installing: /usr/local/include/fastrtps/subscriber/SampleInfo.h
-- Installing: /usr/local/include/fastrtps/subscriber/SubscriberListener.h
-- Installing: /usr/local/include/fastrtps/participant
-- Installing: /usr/local/include/fastrtps/participant/ParticipantListener.h
-- Installing: /usr/local/include/fastrtps/participant/Participant.h
-- Installing: /usr/local/include/fastrtps/fastrtps_fwd.h
-- Installing: /usr/local/include/fastrtps/fastrtps_all.h
-- Installing: /usr/local/include/fastrtps/publisher
-- Installing: /usr/local/include/fastrtps/publisher/PublisherListener.h
-- Installing: /usr/local/include/fastrtps/publisher/Publisher.h
-- Installing: /usr/local/include/fastrtps/publisher/PublisherHistory.h
-- Installing: /usr/local/include/fastrtps/TopicDataType.h
-- Installing: /usr/local/include/fastrtps/types
-- Installing: /usr/local/include/fastrtps/types/AnnotationParameterValue.h
-- Installing: /usr/local/include/fastrtps/types/DynamicDataFactory.h
-- Installing: /usr/local/include/fastrtps/types/AnnotationDescriptor.h
-- Installing: /usr/local/include/fastrtps/types/TypesBase.h
-- Installing: /usr/local/include/fastrtps/types/TypeObjectHashId.h
-- Installing: /usr/local/include/fastrtps/types/DynamicType.h
-- Installing: /usr/local/include/fastrtps/types/DynamicTypeBuilderFactory.h
-- Installing: /usr/local/include/fastrtps/types/DynamicPubSubType.h
-- Installing: /usr/local/include/fastrtps/types/TypeIdentifier.h
-- Installing: /usr/local/include/fastrtps/types/MemberDescriptor.h
-- Installing: /usr/local/include/fastrtps/types/DynamicTypePtr.h
-- Installing: /usr/local/include/fastrtps/types/DynamicData.h
-- Installing: /usr/local/include/fastrtps/types/TypeIdentifierTypes.h
-- Installing: /usr/local/include/fastrtps/types/TypeDescriptor.h
-- Installing: /usr/local/include/fastrtps/types/DynamicTypeMember.h
-- Installing: /usr/local/include/fastrtps/types/TypeObject.h
-- Installing: /usr/local/include/fastrtps/types/DynamicTypeBuilder.h
-- Installing: /usr/local/include/fastrtps/types/TypeObjectFactory.h
-- Installing: /usr/local/include/fastrtps/types/DynamicDataPtr.h
-- Installing: /usr/local/include/fastrtps/types/TypeNamesGenerator.h
-- Installing: /usr/local/include/fastrtps/types/DynamicTypeBuilderPtr.h
-- Installing: /usr/local/include/fastrtps/Domain.h
-- Installing: /usr/local/include/fastrtps/attributes
-- Installing: /usr/local/include/fastrtps/attributes/TopicAttributes.h
-- Installing: /usr/local/include/fastrtps/attributes/all_attributes.h
-- Installing: /usr/local/include/fastrtps/attributes/ParticipantAttributes.h
-- Installing: /usr/local/include/fastrtps/attributes/SubscriberAttributes.h
-- Installing: /usr/local/include/fastrtps/attributes/PublisherAttributes.h
-- Installing: /usr/local/include/fastrtps/config
-- Installing: /usr/local/include/fastrtps/config/doxygen_modules.h
-- Installing: /usr/local/include/fastrtps/rtps
-- Installing: /usr/local/include/fastrtps/rtps/writer
-- Installing: /usr/local/include/fastrtps/rtps/writer/timedevent
-- Installing: /usr/local/include/fastrtps/rtps/writer/timedevent/PeriodicHeartbeat.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/timedevent/NackSupressionDuration.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/timedevent/NackResponseDelay.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/StatelessWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/WriterDiscoveryInfo.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/StatefulWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/StatefulPersistentWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/ReaderLocator.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/WriterListener.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/PersistentWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/RTPSWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/StatelessPersistentWriter.h
-- Installing: /usr/local/include/fastrtps/rtps/writer/ReaderProxy.h
-- Installing: /usr/local/include/fastrtps/rtps/exceptions
-- Installing: /usr/local/include/fastrtps/rtps/exceptions/Exception.h
-- Installing: /usr/local/include/fastrtps/rtps/RTPSDomain.h
-- Installing: /usr/local/include/fastrtps/rtps/network
-- Installing: /usr/local/include/fastrtps/rtps/network/NetworkFactory.h
-- Installing: /usr/local/include/fastrtps/rtps/network/SenderResource.h
-- Installing: /usr/local/include/fastrtps/rtps/network/ReceiverResource.h
-- Installing: /usr/local/include/fastrtps/rtps/flowcontrol
-- Installing: /usr/local/include/fastrtps/rtps/flowcontrol/ThroughputControllerDescriptor.h
-- Installing: /usr/local/include/fastrtps/rtps/Endpoint.h
-- Installing: /usr/local/include/fastrtps/rtps/participant
-- Installing: /usr/local/include/fastrtps/rtps/participant/RTPSParticipantListener.h
-- Installing: /usr/local/include/fastrtps/rtps/participant/RTPSParticipant.h
-- Installing: /usr/local/include/fastrtps/rtps/participant/ParticipantDiscoveryInfo.h
-- Installing: /usr/local/include/fastrtps/rtps/history
-- Installing: /usr/local/include/fastrtps/rtps/history/History.h
-- Installing: /usr/local/include/fastrtps/rtps/history/CacheChangePool.h
-- Installing: /usr/local/include/fastrtps/rtps/history/ReaderHistory.h
-- Installing: /usr/local/include/fastrtps/rtps/history/WriterHistory.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant/timedevent
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant/timedevent/ResendParticipantProxyDataPeriod.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant/timedevent/RemoteParticipantLeaseDuration.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant/PDPSimpleListener.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/participant/PDPSimple.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/endpoint
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/endpoint/EDP.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/endpoint/EDPSimple.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/discovery/endpoint/EDPStatic.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/liveliness
-- Installing: /usr/local/include/fastrtps/rtps/builtin/liveliness/timedevent
-- Installing: /usr/local/include/fastrtps/rtps/builtin/liveliness/timedevent/WLivelinessPeriodicAssertion.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/liveliness/WLP.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/liveliness/WLPListener.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/data
-- Installing: /usr/local/include/fastrtps/rtps/builtin/data/ParticipantProxyData.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/data/WriterProxyData.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/data/ReaderProxyData.h
-- Installing: /usr/local/include/fastrtps/rtps/builtin/BuiltinProtocols.h
-- Installing: /usr/local/include/fastrtps/rtps/reader
-- Installing: /usr/local/include/fastrtps/rtps/reader/ReaderDiscoveryInfo.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/timedevent
-- Installing: /usr/local/include/fastrtps/rtps/reader/timedevent/HeartbeatResponseDelay.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/timedevent/WriterProxyLiveliness.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/timedevent/InitialAckNack.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/StatelessReader.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/WriterProxy.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/StatelessPersistentReader.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/StatefulReader.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/ReaderListener.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/StatefulPersistentReader.h
-- Installing: /usr/local/include/fastrtps/rtps/reader/RTPSReader.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes
-- Installing: /usr/local/include/fastrtps/rtps/attributes/EndpointAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes/ReaderAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes/HistoryAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes/PropertyPolicy.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes/RTPSParticipantAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/attributes/WriterAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/common
-- Installing: /usr/local/include/fastrtps/rtps/common/PortParameters.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Token.h
-- Installing: /usr/local/include/fastrtps/rtps/common/WriteParams.h
-- Installing: /usr/local/include/fastrtps/rtps/common/all_common.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Property.h
-- Installing: /usr/local/include/fastrtps/rtps/common/MatchingInfo.h
-- Installing: /usr/local/include/fastrtps/rtps/common/BinaryProperty.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Types.h
-- Installing: /usr/local/include/fastrtps/rtps/common/SequenceNumber.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Locator.h
-- Installing: /usr/local/include/fastrtps/rtps/common/CacheChange.h
-- Installing: /usr/local/include/fastrtps/rtps/common/SerializedPayload.h
-- Installing: /usr/local/include/fastrtps/rtps/common/InstanceHandle.h
-- Installing: /usr/local/include/fastrtps/rtps/common/FragmentNumber.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Time_t.h
-- Installing: /usr/local/include/fastrtps/rtps/common/SampleIdentity.h
-- Installing: /usr/local/include/fastrtps/rtps/common/CDRMessage_t.h
-- Installing: /usr/local/include/fastrtps/rtps/common/Guid.h
-- Installing: /usr/local/include/fastrtps/rtps/rtps_fwd.h
-- Installing: /usr/local/include/fastrtps/rtps/messages
-- Installing: /usr/local/include/fastrtps/rtps/messages/CDRMessage.h
-- Installing: /usr/local/include/fastrtps/rtps/messages/CDRMessagePool.h
-- Installing: /usr/local/include/fastrtps/rtps/messages/RTPSMessageCreator.h
-- Installing: /usr/local/include/fastrtps/rtps/messages/RTPS_messages.h
-- Installing: /usr/local/include/fastrtps/rtps/messages/CDRMessage.hpp
-- Installing: /usr/local/include/fastrtps/rtps/messages/RTPSMessageGroup.h
-- Installing: /usr/local/include/fastrtps/rtps/messages/MessageReceiver.h
-- Installing: /usr/local/include/fastrtps/rtps/security
-- Installing: /usr/local/include/fastrtps/rtps/security/accesscontrol
-- Installing: /usr/local/include/fastrtps/rtps/security/accesscontrol/EndpointSecurityAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/security/accesscontrol/ParticipantSecurityAttributes.h
-- Installing: /usr/local/include/fastrtps/rtps/security/accesscontrol/SecurityMaskUtilities.h
-- Installing: /usr/local/include/fastrtps/rtps/security/accesscontrol/AccessControl.h
-- Installing: /usr/local/include/fastrtps/rtps/security/exceptions
-- Installing: /usr/local/include/fastrtps/rtps/security/exceptions/SecurityException.h
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography/Cryptography.h
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography/CryptoKeyFactory.h
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography/CryptoTypes.h
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography/CryptoKeyExchange.h
-- Installing: /usr/local/include/fastrtps/rtps/security/cryptography/CryptoTransform.h
-- Installing: /usr/local/include/fastrtps/rtps/security/authentication
-- Installing: /usr/local/include/fastrtps/rtps/security/authentication/Handshake.h
-- Installing: /usr/local/include/fastrtps/rtps/security/authentication/Authentication.h
-- Installing: /usr/local/include/fastrtps/rtps/security/common
-- Installing: /usr/local/include/fastrtps/rtps/security/common/ParticipantGenericMessage.h
-- Installing: /usr/local/include/fastrtps/rtps/security/common/Handle.h
-- Installing: /usr/local/include/fastrtps/rtps/security/common/SharedSecretHandle.h
-- Installing: /usr/local/include/fastrtps/rtps/resources
-- Installing: /usr/local/include/fastrtps/rtps/resources/ResourceManagement.h
-- Installing: /usr/local/include/fastrtps/rtps/resources/AsyncInterestTree.h
-- Installing: /usr/local/include/fastrtps/rtps/resources/TimedEvent.h
-- Installing: /usr/local/include/fastrtps/rtps/resources/ResourceEvent.h
-- Installing: /usr/local/include/fastrtps/rtps/resources/AsyncWriterThread.h
-- Installing: /usr/local/include/fastrtps/rtps/rtps_all.h
-- Installing: /usr/local/include/fastrtps/eProsima_auto_link.h
-- Installing: /usr/local/include/fastrtps/transport
-- Installing: /usr/local/include/fastrtps/transport/TransportReceiverInterface.h
-- Installing: /usr/local/include/fastrtps/transport/timedevent
-- Installing: /usr/local/include/fastrtps/transport/timedevent/CleanTCPSocketsEvent.h
-- Installing: /usr/local/include/fastrtps/transport/test_UDPv4Transport.h
-- Installing: /usr/local/include/fastrtps/transport/UDPv4Transport.h
-- Installing: /usr/local/include/fastrtps/transport/UDPv4TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/UDPTransportInterface.h
-- Installing: /usr/local/include/fastrtps/transport/SocketTransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/TCPv6Transport.h
-- Installing: /usr/local/include/fastrtps/transport/TCPTransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/UDPChannelResource.h
-- Installing: /usr/local/include/fastrtps/transport/TCPv4Transport.h
-- Installing: /usr/local/include/fastrtps/transport/TransportInterface.h
-- Installing: /usr/local/include/fastrtps/transport/tcp
-- Installing: /usr/local/include/fastrtps/transport/tcp/RTCPHeader.h
-- Installing: /usr/local/include/fastrtps/transport/tcp/TCPControlMessage.h
-- Installing: /usr/local/include/fastrtps/transport/tcp/test_RTCPMessageManager.h
-- Installing: /usr/local/include/fastrtps/transport/tcp/RTCPMessageManager.h
-- Installing: /usr/local/include/fastrtps/transport/TCPTransportInterface.h
-- Installing: /usr/local/include/fastrtps/transport/UDPv6TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/test_UDPv4TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/test_TCPv4Transport.h
-- Installing: /usr/local/include/fastrtps/transport/UDPTransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/test_TCPv4TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/TransportDescriptorInterface.h
-- Installing: /usr/local/include/fastrtps/transport/TCPChannelResource.h
-- Installing: /usr/local/include/fastrtps/transport/UDPv6Transport.h
-- Installing: /usr/local/include/fastrtps/transport/ChannelResource.h
-- Installing: /usr/local/include/fastrtps/transport/TCPv6TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/transport/TCPv4TransportDescriptor.h
-- Installing: /usr/local/include/fastrtps/utils
-- Installing: /usr/local/include/fastrtps/utils/IPFinder.h
-- Installing: /usr/local/include/fastrtps/utils/ObjectPool.h
-- Installing: /usr/local/include/fastrtps/utils/System.h
-- Installing: /usr/local/include/fastrtps/utils/IPLocator.h
-- Installing: /usr/local/include/fastrtps/utils/md5.h
-- Installing: /usr/local/include/fastrtps/utils/Semaphore.h
-- Installing: /usr/local/include/fastrtps/utils/eClock.h
-- Installing: /usr/local/include/fastrtps/utils/TimeConversion.h
-- Installing: /usr/local/include/fastrtps/utils/DBQueue.h
-- Installing: /usr/local/include/fastrtps/utils/StringMatching.h
-- Installing: /usr/local/include/fastrtps/config.h
-- Installing: /usr/local/lib/libfastrtps.so.1.7.0
-- Installing: /usr/local/lib/libfastrtps.so.1
-- Installing: /usr/local/lib/libfastrtps.so
-- Set runtime path of "/usr/local/lib/libfastrtps.so.1.7.0" to ""
-- Installing: /usr/local/share/fastrtps/cmake/fastrtps-targets.cmake
-- Installing: /usr/local/share/fastrtps/cmake/fastrtps-targets-release.cmake
-- Installing: /usr/local/share/fastrtps/cmake/fastrtps-config.cmake
-- Installing: /usr/local/share/fastrtps/cmake/fastrtps-config-version.cmake

======================== インストールに成功しました ==========================

Some of the files created by the installation are inside the home directory: /home

You probably don't want them to be included in the package.
それらを表示しますか？ [n]: 
それらをパッケージから除外しますか？(yesと答えることをおすすめします) [n]: 

Some of the files created by the installation are inside the build
directory: /home/kenta/git/Fast-RTPS/build

You probably don't want them to be included in the package,
especially if they are inside your home directory.
Do you want me to list them?  [n]: 
それらをパッケージから除外しますか？(yesと答えることをおすすめします) [y]: 

tempディレクトリにファイルをコピー..OK

Stripping ELF binaries and libraries...OK

manページを圧縮..OK

ファイルリストを作成..OK

Debianパッケージを作成..OK

Debianパッケージをインストール..OK

tempファイルを削除..OK

バックアップパッケージを書き込み..OK
OK

temp dirを削除..OK


**********************************************************************

 Done. The new package has been installed and saved to

 /home/kenta/git/Fast-RTPS/build/fastrtps_20190522-1_amd64.deb

 You can remove it from your system anytime using: 

      dpkg -r fastrtps

**********************************************************************

$ dpkg --get-selections | grep fastrtps
fastrtps                                        install
$ which fastrtpsgen
/usr/local/bin/fastrtpsgen
```

これでインストールが完了した！

## サンプルプログラムを動かす

fastrtpsgenを使ってサンプルプログラムを作成する．
プログラムの作成は[FASTRTPSGEN v1.0.4 USER MANUAL](https://eprosima.com/docs/fast-rtps/1.0.4/pdf/FASTRTPSGEN_User_Manual.pdf)の`4 HelloWorld example`を参考にした．

```shell
$ mkdir fastrtps-HelloWorld; cd fastrtps-HelloWorld
$ vim HelloWorld.idl # メッセージを定義
$ cat HelloWorld.idl
struct sample {
    @Key long id;
    string message;
};
$ fastrtpsgen HelloWorld.idl -example CMake
openjdk version "1.8.0_212"
OpenJDK Runtime Environment (build 1.8.0_212-8u212-b03-0ubuntu1.16.04.1-b03)
OpenJDK 64-Bit Server VM (build 25.212-b03, mixed mode)
Loading templates...
Processing the file HelloWorld.idl...
HelloWorld.idl:2:16: error: Illegal identifier: id is already defined (Annotation: id)
Exception in thread "main" java.lang.NullPointerException
        at com.eprosima.fastrtps.fastrtpsgen.execute(fastrtpsgen.java:323)
        at com.eprosima.fastrtps.fastrtpsgen.main(fastrtpsgen.java:1188)
```

サンプルコードが動かない．
idは定義済みだそうだ．
別の名前を付けて再度挑戦してみる．

```shell
$ vim HelloWorld.idl 
$ cat HelloWorld.idl 
struct HelloWorld {
    @Key long index;
    string message;
};
$ fastrtpsgen HelloWorld.idl -example CMake
openjdk version "1.8.0_212"
OpenJDK Runtime Environment (build 1.8.0_212-8u212-b03-0ubuntu1.16.04.1-b03)
OpenJDK 64-Bit Server VM (build 25.212-b03, mixed mode)
Loading templates...
Processing the file HelloWorld.idl...
Generating Type definition files...
Generating TopicDataTypes files...
Generating Publisher files...
Generating Subscriber files...
Generating main file...
Adding project: HelloWorld.idl
Generating solution for arch CMake...
Generating CMakeLists solution
$ ls 
CMakeLists.txt  HelloWorldPubSubMain.cxx   HelloWorldPublisher.h
HelloWorld.cxx  HelloWorldPubSubTypes.cxx  HelloWorldSubscriber.cxx
HelloWorld.h    HelloWorldPubSubTypes.h    HelloWorldSubscriber.h
HelloWorld.idl  HelloWorldPublisher.cxx
```

ファイルが生成された．これをビルドする．

```shell
$ mkdir build; cd build
$ cmake ../
-- The C compiler identification is GNU 5.4.0
-- The CXX compiler identification is GNU 5.4.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Found OpenSSL: /usr/lib/x86_64-linux-gnu/libssl.so;/usr/lib/x86_64-linux-gnu/libcrypto.so (found version "1.0.2g") 
-- Configuring HelloWorld...
-- Configuring done
-- Generating done
-- Build files have been written to: /home/kenta/prog/c++/fastrtps-HelloWorld/build
$ make
Scanning dependencies of target HelloWorld_lib
[ 14%] Building CXX object CMakeFiles/HelloWorld_lib.dir/HelloWorld.cxx.o
[ 28%] Linking CXX static library libHelloWorld_lib.a
[ 28%] Built target HelloWorld_lib
Scanning dependencies of target HelloWorld
[ 42%] Building CXX object CMakeFiles/HelloWorld.dir/HelloWorldPubSubTypes.cxx.o
[ 57%] Building CXX object CMakeFiles/HelloWorld.dir/HelloWorldPubSubMain.cxx.o
[ 85%] Building CXX object CMakeFiles/HelloWorld.dir/HelloWorldPublisher.cxx.o
[ 85%] Building CXX object CMakeFiles/HelloWorld.dir/HelloWorldSubscriber.cxx.o
[100%] Linking CXX executable HelloWorld
[100%] Built target HelloWorld
$ ls
$ ls
CMakeCache.txt  CMakeFiles  HelloWorld  Makefile  cmake_install.cmake  libHelloWorld_lib.a
$ ./HelloWorld 
Error: Incorrect arguments.
Usage: 

./HelloWorld publisher|subscriber
```

ターミナルを二つ用意し，それぞれで`./HelloWorld publisher`と`./HelloWorld subscriber`を実行する．

```shell
$ ./HelloWorld publisher
Starting 
Publisher created, waiting for Subscribers.
Publisher matched
Sending sample, count=1, send another sample?(y-yes,n-stop): n
Stopping execution
```

```shell
$ ./HelloWorld subscriber
Starting 
Waiting for Data, press Enter to stop the Subscriber. 
Subscriber matched
Sample received, count=1
Subscriber unmatched
```

Fast-RTPSを使って通信ができた．
