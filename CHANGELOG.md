# v5.4.1
## 27 Apr 2018 — 22:48:54 UTC

### fix

+ __PostgresGrammar:__ Fix typo in getAllTableNames ([91caf6a](https://github.com/coldbox-modules/qb/commit/91caf6a467fa585fdeef26e08171b59ff71b59e1))
+ __SchemaBuilder:__ Fix dropping foreign keys in MySQL ([8895447](https://github.com/coldbox-modules/qb/commit/8895447cf3a0c36c2579a2867f0510033a28b0b7))

### other

+ __\*:__ Updated API Docs ([84913a9](https://github.com/coldbox-modules/qb/commit/84913a9cabf35fc2429787d1b7f4a37dfadb4e50))


# v5.4.0
## 16 Apr 2018 — 21:36:02 UTC

### feat

+ __AutoDiscover:__ Allow for runtime discovery ([700948a](https://github.com/coldbox-modules/qb/commit/700948a6ac503b7af59efb0e00894c211c3d8882))

### other

+ __\*:__ Updated API Docs ([f078222](https://github.com/coldbox-modules/qb/commit/f0782223d11052c560d45a6f120eb56402949d20))


# v5.3.1
## 28 Mar 2018 — 22:12:45 UTC

### fix

+ __ModuleConfig:__ Fix logic for determining CommandBox vs ColdBox environment ([5c66466](https://github.com/coldbox-modules/qb/commit/5c66466b11707342265a9589fefe016df134cb48))

### other

+ __\*:__ Updated API Docs ([9136823](https://github.com/coldbox-modules/qb/commit/913682381ec4ad6627a4c136d191a3b637fa4d75))


# v5.3.0
## 26 Mar 2018 — 16:15:55 UTC

### chore

+ __README:__ Update references to elpete to coldbox-modules ([bc7c99c](https://github.com/coldbox-modules/qb/commit/bc7c99c5f32c71bd899321dc3909313c17beb853))

### feat

+ __ModuleConfig:__ Auto discover grammar by default. ([b2347ae](https://github.com/coldbox-modules/qb/commit/b2347aebae9ca5a42655b0f7ed5fd2ed6ec804fb))

### fix

+ __ModuleConfig:__ Add PostgresGrammar alias to WireBox ([eca03f0](https://github.com/coldbox-modules/qb/commit/eca03f0594147c9323bc99ddd9505b8e7b4c6571))

### other

+ __\*:__ Updated API Docs ([654eb0c](https://github.com/coldbox-modules/qb/commit/654eb0c67e69c06e3f3fc6bc17c3fef26b95ee54))


# v5.2.1
## 14 Mar 2018 — 03:18:19 UTC

### fix

+ __QueryBuilder:__ Preserve returnFormat when creating a new builder ([4538947](https://github.com/coldbox-modules/qb/commit/4538947807d3c33865281bdf7852b858c393dbfb))

### other

+ __\*:__ Updated API Docs ([6bd1da1](https://github.com/coldbox-modules/qb/commit/6bd1da1c68ecd11227d575f9f6b0de652188633f))


# v5.2.0
## 12 Mar 2018 — 21:33:37 UTC

### feat

+ __Grammar:__ Added official support for MSSQL, Oracle, and Postgres. (#34) ([733dae3](https://github.com/coldbox-modules/qb/commit/733dae3498814f49a829b604799824e9f755bb85))

### other

+ __\*:__ Updated API Docs ([b99e000](https://github.com/coldbox-modules/qb/commit/b99e00030a2451807e3d7df9e365ee86e7be8543))


# v5.1.2
## 20 Feb 2018 — 06:59:54 UTC

### other

+ __\*:__ Updated API Docs ([fae1106](https://github.com/coldbox-modules/qb/commit/fae11067373d1e63d64318b4e27ec19aff16c4ce))

### perf

+ __QueryBuilder:__ Replace normalizeToArray with simpler Array check ([d54bcce](https://github.com/coldbox-modules/qb/commit/d54bccec88da95f2982423ea7bfbd0785e2e8d7b))
+ __BaseGrammar:__ Avoid isInstanceOf in wrapColumn ([15042ce](https://github.com/coldbox-modules/qb/commit/15042ce04384536ecda2f06148481bd32b252eb8))


# v5.1.1
## 19 Feb 2018 — 18:03:58 UTC

### fix

+ __MySQLGrammar:__ Default to CURRENT_TIMESTAMP for timestamp columns (#32) ([680750a](https://github.com/coldbox-modules/qb/commit/680750a9894c56271cc7748a6dc501c2c266ea85))

### other

+ __\*:__ Updated API Docs ([f78a21a](https://github.com/coldbox-modules/qb/commit/f78a21aaae8cb8fb1a475fa2f74acbafd506015f))


# v5.1.0
## 16 Feb 2018 — 22:23:59 UTC

### feat

+ __SchemaBuilder:__ Add dropAllObjects action. (#31) ([c3e23b5](https://github.com/coldbox-modules/qb/commit/c3e23b5c110fae3464d48d62ae80e357e8c38842))

### other

+ __\*:__ Updated API Docs ([b1499a3](https://github.com/coldbox-modules/qb/commit/b1499a3de00191478aa916aec368dc40c68319b7))


# v5.0.3
## 16 Feb 2018 — 21:10:33 UTC

### chore

+ __build:__ Enable commandbox-semantic-release ([0fe689f](https://github.com/coldbox-modules/qb/commit/0fe689f77b19124271a68293baa6a22b157a3cfd))

### errors

+ __schema:__ Better error message when passing in a TableIndex to create column ([f91a3f7](https://github.com/coldbox-modules/qb/commit/f91a3f7f4f4ae1bd513139fbb1ccfc52eef4874a))

### other

+ __\*:__ Updated API Docs ([dfd9510](https://github.com/coldbox-modules/qb/commit/dfd95103411c2fabaa0cac1cd8e681b9d088b614))
+ __\*:__ Update references from Builder to QueryBuilder ([632e697](https://github.com/coldbox-modules/qb/commit/632e697c5b37d8e6ea522efc628f487dc4e14403))
+ __\*:__ Updated API Docs ([8325db5](https://github.com/coldbox-modules/qb/commit/8325db5d232c55f3b433e4d528a43b72d7622fd9))
