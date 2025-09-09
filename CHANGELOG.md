## [1.5.4](https://github.com/magebase/base-infra/compare/v1.5.3...v1.5.4) (2025-09-09)


### Bug Fixes

* add validation for empty tag values and improve commit message accuracy ([4df06ce](https://github.com/magebase/base-infra/commit/4df06ce8cc68a51f109e5bf5a36d55f1b545957a))
* remove semantic-release job from update-argocd-on-release workflow ([a32750c](https://github.com/magebase/base-infra/commit/a32750c9bb6bce6f091ead40c82a8bea4da77e5b))
* replace PR creation with direct commit to main for targetRevision updates ([8ea02f4](https://github.com/magebase/base-infra/commit/8ea02f48732201453d9075ccaf0e932174c05cdb))
* restore dev targetRevision for magebase/site to v1.2.1 ([2548b3b](https://github.com/magebase/base-infra/commit/2548b3b202a40602812b97e50f1fe61be160dbcd))

## [1.5.3](https://github.com/magebase/base-infra/compare/v1.5.2...v1.5.3) (2025-09-09)


### Bug Fixes

* use proper newlines in release notes for markdown formatting ([0276b6a](https://github.com/magebase/base-infra/commit/0276b6a1a2f378aa41529994e2676ebdeaa0ba7c))

## [1.5.2](https://github.com/magebase/base-infra/compare/v1.5.1...v1.5.2) (2025-09-09)


### Bug Fixes

* add 'v' prefix to release version for gh release edit command ([2e2df13](https://github.com/magebase/base-infra/commit/2e2df13dbd1fdb272b3a992f959494bcde8d53cf))
* correct jq command formatting in workflow verification steps ([0b61d0e](https://github.com/magebase/base-infra/commit/0b61d0e30262a721036b51ffcadb39178eb8fb4d))

## [1.5.1](https://github.com/magebase/base-infra/compare/v1.5.0...v1.5.1) (2025-09-09)


### Bug Fixes

* resolve release timing issues and update promotion workflow ([9c120e3](https://github.com/magebase/base-infra/commit/9c120e32d53d47f6e21c738324a1010faa4335a2))

# [1.5.0](https://github.com/magebase/base-infra/compare/v1.4.1...v1.5.0) (2025-09-09)


### Features

* add targetRevision fields to clients.json and use env vars in templates ([d0ec8f7](https://github.com/magebase/base-infra/commit/d0ec8f7646578b2669111755bcf936794fa9af26))

## [1.4.1](https://github.com/magebase/base-infra/compare/v1.4.0...v1.4.1) (2025-09-09)


### Bug Fixes

* enhance error handling in Docker image link step ([4eacb22](https://github.com/magebase/base-infra/commit/4eacb22cad49793bfe51b2d5573092b92bc198f9))

# [1.4.0](https://github.com/magebase/base-infra/compare/v1.3.5...v1.4.0) (2025-09-09)


### Bug Fixes

* reduce Knative serving component resource requests for small cluster ([09260a5](https://github.com/magebase/base-infra/commit/09260a536fb0e6c17e36aec2cdb2c572d88f1e31))
* update Knative serving-core image references to v1.18.1 ([909cb5e](https://github.com/magebase/base-infra/commit/909cb5ef5a569b071492bce929b5126c5c022366))


### Features

* implement dynamic client configuration system ([3336b5e](https://github.com/magebase/base-infra/commit/3336b5e498a97db3e7e6e9012aaeb532c6c4c390))

## [1.3.5](https://github.com/magebase/base-infra/compare/v1.3.4...v1.3.5) (2025-09-09)


### Bug Fixes

* implement permanent knative webhook infrastructure fixes ([460b3a6](https://github.com/magebase/base-infra/commit/460b3a6a2e721f72124fc6e2655923bbb764d831))

## [1.3.4](https://github.com/magebase/base-infra/compare/v1.3.3...v1.3.4) (2025-09-09)


### Bug Fixes

* remove conflicting argocd-allow network policy ([5c7d8dc](https://github.com/magebase/base-infra/commit/5c7d8dced176e7c139db5cc7db4a16eb02784214))

## [1.3.3](https://github.com/magebase/base-infra/compare/v1.3.2...v1.3.3) (2025-09-08)


### Bug Fixes

* Update ExternalSecret API versions to v1 for ESO 0.19.2 compatibility ([74ba34e](https://github.com/magebase/base-infra/commit/74ba34e96aa6e6368f7b5d3f9470ed4ccb5e6420))
* Update StackGres operator deployment to version 1.17.2 ([487c6d1](https://github.com/magebase/base-infra/commit/487c6d198bc34bb117b1086f5f74899ab0c37682))

## [1.3.2](https://github.com/magebase/base-infra/compare/v1.3.1...v1.3.2) (2025-09-08)


### Bug Fixes

* Remove duplicate ExternalSecret resources from database templates ([fdacefd](https://github.com/magebase/base-infra/commit/fdacefd42879add98c29905dc9b9f958520dfd0a))

## [1.3.1](https://github.com/magebase/base-infra/compare/v1.3.0...v1.3.1) (2025-09-08)


### Bug Fixes

* Update database templates to fix SGObjectStorage and Secret issues ([121bd3e](https://github.com/magebase/base-infra/commit/121bd3e5d6807a6af50ef3651ee459e6f9f4d7a0))

# [1.3.0](https://github.com/magebase/base-infra/compare/v1.2.0...v1.3.0) (2025-09-08)


### Bug Fixes

* add granular checkpoint tracking and timeout handling for operator installations ([4f5f6a2](https://github.com/magebase/base-infra/commit/4f5f6a2b99d39392d14c10f3bfc10aa2ae1cf4b7))
* Add Replace sync option to fix CRD annotation size limits ([dfd8526](https://github.com/magebase/base-infra/commit/dfd852602ac88d97994199817f52945ad9f8b950))
* enhance ESO and StackGres webhook configuration cleanup ([0e83df4](https://github.com/magebase/base-infra/commit/0e83df4193929e505095bc4a3c9c44916073cb7a))
* prevent Helm installation timeouts with async deployment ([4d9ae0c](https://github.com/magebase/base-infra/commit/4d9ae0cea1b38f95252ade5580723624beefd73d))
* remove references to non-existent environment files in argocd applications kustomization ([ccd6d97](https://github.com/magebase/base-infra/commit/ccd6d973c40559e6c1c15a219c01012833ec9c8b))
* Update operator applications to fix deployment issues ([3cb4848](https://github.com/magebase/base-infra/commit/3cb48480a666b181ff922c7ccb410a3ac10a01dc))


### Features

* Transition to GitOps operator management ([497e72c](https://github.com/magebase/base-infra/commit/497e72c590c17e12947af6f6b710a1dcfe43882b))

# [1.2.0](https://github.com/magebase/base-infra/compare/v1.1.4...v1.2.0) (2025-09-08)


### Bug Fixes

* add stackgres setup, operator and ssm connecton string sharing ([712ce1a](https://github.com/magebase/base-infra/commit/712ce1a8990ab596da505f5ad62b9f6ab2b451d0))


### Features

* Add database URL secrets and horizontal autoscaling to Citus clusters ([bac82b6](https://github.com/magebase/base-infra/commit/bac82b65d10e749fecd5b5e06b33c492fe190ce9))
* Implement complete StackGres database connectivity solution ([19bf328](https://github.com/magebase/base-infra/commit/19bf32889078ae141146219279f8afb6dc782224))
* Install StackGres with Citus extension to replace YugabyteDB ([07f04e7](https://github.com/magebase/base-infra/commit/07f04e74b97f0a9d63ddfdc390061e4865733d52))
* Make MinIO credentials configurable through Kustomize parameters ([152b6f0](https://github.com/magebase/base-infra/commit/152b6f0bf58a01d4ea999957dce38de22fdeaf17))
* Update all Citus clusters to minimum specs with autoscaling ([33db19c](https://github.com/magebase/base-infra/commit/33db19c9bf0834ade973a63eda1921f648354f25))
* Update Citus configurations to use R2 environment variables ([c9d28bf](https://github.com/magebase/base-infra/commit/c9d28bf612757de66850a60d4c73db63e141d020))
* Update SGObjectStorage to use S3-compatible storage with MinIO ([4c54887](https://github.com/magebase/base-infra/commit/4c5488797e8851e788be1f6b134bf6e35b5d19e7))

## [1.1.4](https://github.com/magebase/base-infra/compare/v1.1.3...v1.1.4) (2025-09-07)


### Bug Fixes

* release argocd ([3346602](https://github.com/magebase/base-infra/commit/3346602d614b766f1cf54307e03dbb0b0a5e9ac2))

## [1.1.3](https://github.com/magebase/base-infra/compare/v1.1.2...v1.1.3) (2025-09-07)


### Bug Fixes

* Remove global namespace transformation from ESO kustomization ([f0e409f](https://github.com/magebase/base-infra/commit/f0e409fbeeceea68d50bcd35175ce303b9d91cfb))

## [1.1.2](https://github.com/magebase/base-infra/compare/v1.1.1...v1.1.2) (2025-09-07)


### Bug Fixes

* kustomize url ([f676280](https://github.com/magebase/base-infra/commit/f6762807a8d7a45644157f65db0f9174f2553f8f))

## [1.1.1](https://github.com/magebase/base-infra/compare/v1.1.0...v1.1.1) (2025-09-07)


### Bug Fixes

* Add missing kustomize parameters for ESO templates ([f0456b7](https://github.com/magebase/base-infra/commit/f0456b7d11cebdb0b8bba9ec4ff56acafcb4626d))

# [1.1.0](https://github.com/magebase/base-infra/compare/v1.0.1...v1.1.0) (2025-09-07)


### Features

* Convert ESO from IAM roles to IAM users for Hetzner k3s ([4c2837f](https://github.com/magebase/base-infra/commit/4c2837fa3de6206e4916b168771977d9d66f5eac))

## [1.0.1](https://github.com/magebase/base-infra/compare/v1.0.0...v1.0.1) (2025-09-07)


### Bug Fixes

* irsa ([c1a7129](https://github.com/magebase/base-infra/commit/c1a712969f10f2a09ece9c0115cfe37b00240530))

# 1.0.0 (2025-09-07)


### Bug Fixes

* add bootstrap ([dc2d95b](https://github.com/magebase/base-infra/commit/dc2d95b59db946a6e76a705c95f86a5b60575b30))
* add bootstrap step ([5f7bd98](https://github.com/magebase/base-infra/commit/5f7bd982d465dc1bf298ba63659ef2a124d80322))
* add data sources to check for existing SES DNS records before creation ([9d61037](https://github.com/magebase/base-infra/commit/9d61037a1deb286c9332275c922d3805b8a84c73))
* add Docker authentication to security scan job ([57ee6ce](https://github.com/magebase/base-infra/commit/57ee6cedb347a41cd371460e3e62c1fb5d2cbce0))
* Add ENCRYPTION_KEY variable to resolve Terraform template error ([ac59163](https://github.com/magebase/base-infra/commit/ac5916337b0547ba5daa0927d177bc48942ad200))
* add environment-specific .tfvars files to git ([35e0350](https://github.com/magebase/base-infra/commit/35e03506e94e0a8929568a2da2f3cecfc79b12de))
* add github pat secrets ([c1ae3c2](https://github.com/magebase/base-infra/commit/c1ae3c22e92e0773a56320764c9bf2358d2f25ad))
* add image availability check to security scan ([b0e0965](https://github.com/magebase/base-infra/commit/b0e0965eea367eaf30065d1743689587c33043cf))
* add management var ([5790b11](https://github.com/magebase/base-infra/commit/5790b118b73ef5ab6aaaa42bfbc0326756d21cc6))
* add management var ([9ef84f1](https://github.com/magebase/base-infra/commit/9ef84f14317f6eced8c33a784bfc255bdff31c60))
* Add missing Cloudflare API token to base infrastructure workflow ([020bc8a](https://github.com/magebase/base-infra/commit/020bc8ace4ecc723d9373d2a32918adee72ee70b))
* add missing SSH variables to Terraform commands ([73cd0d9](https://github.com/magebase/base-infra/commit/73cd0d9e55c4a7edb560a0076af1e0c8e1517a72))
* add necessary permissions for semantic-release ([04c9d82](https://github.com/magebase/base-infra/commit/04c9d82c63a74772b84ea5e7a0fb077931b2d065))
* add packages: write permission for GHCR deployment ([e6e422f](https://github.com/magebase/base-infra/commit/e6e422fa028c497db31d35962efe82c78ee20b25))
* add passthrough on traefik argocd ingress ([d7aca3c](https://github.com/magebase/base-infra/commit/d7aca3c5b51568608d2a9d90ba6cd0a406cd5f90))
* Add provider configs to clean up orphaned IAM resources ([d743d6c](https://github.com/magebase/base-infra/commit/d743d6c8cd2edf66a466f922f695ecdec2b92b07))
* add sso ([ca6d3cc](https://github.com/magebase/base-infra/commit/ca6d3ccc4fe15af5608aa4a237959a70164460fd))
* add sso ([5ade5a8](https://github.com/magebase/base-infra/commit/5ade5a830ad1e725102346d3cb1104f146d400ff))
* add sso ([9546aa4](https://github.com/magebase/base-infra/commit/9546aa4580051c686f86ab92104917a43054a807))
* add sso ([5df7027](https://github.com/magebase/base-infra/commit/5df7027e9eb6357f83624a0595482ee9029eaec2))
* Add state cleanup step and fix account IDs ([8ea5248](https://github.com/magebase/base-infra/commit/8ea5248ad4ae18afeccfb071eaef3bbefbca4b49))
* add terraform validate to pre-commit and resolve duplicate resources ([4a4e2a0](https://github.com/magebase/base-infra/commit/4a4e2a0cc3b381c2e76785ba45e3411b8de00da2))
* align pre-commit and CI linting configurations ([6d7422f](https://github.com/magebase/base-infra/commit/6d7422f20cdde618601ef6227c311fcedc398a00))
* allow assume ([d291070](https://github.com/magebase/base-infra/commit/d2910701015e4a260ae047978a6b340075e9a428))
* always run apply base-infrastructure ([8c28a0c](https://github.com/magebase/base-infra/commit/8c28a0c98d8d4e4af011b0f45446a8cb1ff1baf1))
* argocd-redis secret ([84bb12c](https://github.com/magebase/base-infra/commit/84bb12ccac62b60058a1b79b57c04fa2d614064b))
* base infrastructure ([340cf83](https://github.com/magebase/base-infra/commit/340cf831df94985f7b2d0bda321cec8202b5269e))
* boostrap ([8cadc73](https://github.com/magebase/base-infra/commit/8cadc73728e60b669640b89ee253495bb59b52ff))
* bundle audit CI command and add missing dependencies ([176c364](https://github.com/magebase/base-infra/commit/176c364a1b3419f3afd8aa492b1db3f5d598e4c2))
* cd into ([cbb48f8](https://github.com/magebase/base-infra/commit/cbb48f8643cd5241d5ebfe6c6917749d93d69f5e))
* cd into ([d7d4ce9](https://github.com/magebase/base-infra/commit/d7d4ce9855846efd628324271ff67cbb43041ea2))
* cd into ([6148a05](https://github.com/magebase/base-infra/commit/6148a05eeae7e037a7be257528de14ae3e85bee7))
* cd into ([ef8c5aa](https://github.com/magebase/base-infra/commit/ef8c5aae80dcc0bfbcc740b8001efe8c314726c1))
* cd into ([d3aaf8b](https://github.com/magebase/base-infra/commit/d3aaf8b8461e639c8cab0a43d854a17168dea349))
* cd into ([bb5c100](https://github.com/magebase/base-infra/commit/bb5c1003c896175eb47b4e7b9e12c8814e9b4245))
* change cf provider to version 5 ([280e428](https://github.com/magebase/base-infra/commit/280e4288b754a6d19b24eea0d289c46969d76255))
* change cp node to cax11 ([9dba862](https://github.com/magebase/base-infra/commit/9dba862714276abfbfa9aea72493eea400453f03))
* combine pipelines ([ca7b062](https://github.com/magebase/base-infra/commit/ca7b062b52c6a805374a627f65f421bcc79a8b16))
* correct ArgoCD variable templating for Kustomize ([b34c8c1](https://github.com/magebase/base-infra/commit/b34c8c1896175dc87aeeffe42f75741f070b5608))
* Correct ARGOCD_ADMIN_PASSWORD variable name in kustomization template ([4615e8d](https://github.com/magebase/base-infra/commit/4615e8d9c7cdc51dac13ba70e62153711d8e137f))
* correct bundle audit and brakeman commands in CI workflow ([e388651](https://github.com/magebase/base-infra/commit/e3886513e155e22a41c1ff5a0b554871f49bb729))
* correct Cloudflare data source syntax and references ([557991d](https://github.com/magebase/base-infra/commit/557991dc69c1aa006d6f71f9f16c27e8c6c5a780))
* Correct DOMAIN variable name case in Terraform config ([5c45ebc](https://github.com/magebase/base-infra/commit/5c45ebcdd5a9efcc95cf458edfeb5663d8446492))
* Create cleanup roles with IAM permissions for orphaned resources ([7abc698](https://github.com/magebase/base-infra/commit/7abc698610b4b2ede5ad1db4c959b6d98fb5e6f2))
* create SESManagerRole with proper trust policy for GitHubActionsSSORole ([ae2c4ac](https://github.com/magebase/base-infra/commit/ae2c4ac960a59de5b8afa80092c447ba3ffe3fac))
* deploy ([53fa105](https://github.com/magebase/base-infra/commit/53fa10578066eb8c52df8a3db2aae94c6a6e0c2b))
* deploy k3s ([c923e41](https://github.com/magebase/base-infra/commit/c923e41d1a065e6ece44a316aaec172924f76872))
* deployment ([48da7f8](https://github.com/magebase/base-infra/commit/48da7f8049f22d5becefd5aaced1b82f0c4645e2))
* deployment ([fe0997f](https://github.com/magebase/base-infra/commit/fe0997f348c4f6f6bae53712cd78ce9581acda98))
* deployment ([5b7d8a0](https://github.com/magebase/base-infra/commit/5b7d8a0523983ddccf25764ae3563afa0b5e03de))
* destroy ([1e40cf5](https://github.com/magebase/base-infra/commit/1e40cf505d3a243a182b7c1a32f9a8deacddcdd2))
* destroy ([06eec9d](https://github.com/magebase/base-infra/commit/06eec9d876b24081111d3a69e72b2fc444d3c5d0))
* destroy ([c1a4da7](https://github.com/magebase/base-infra/commit/c1a4da7da84959a42c9b668092c55b3ba6dc540b))
* downgrade kube-hetzner to v2.15.4 for Terraform 1.8.0 compatibility ([c59fa95](https://github.com/magebase/base-infra/commit/c59fa95c857c0a691d5732d7baf4907f8b3a4a3d))
* downgrade kube-hetzner to v2.17.0 to resolve validation bug ([c8a05d3](https://github.com/magebase/base-infra/commit/c8a05d3573723a9cb7cf30c2993cdcdf5af93708))
* email ([75dc62e](https://github.com/magebase/base-infra/commit/75dc62e6ead9d4eff1d517238c0cd2e8cff2e143))
* ensure ArgoCD Application is created in default namespace ([7cf65c1](https://github.com/magebase/base-infra/commit/7cf65c1ea1fb1ee9e79f223cb647d3fb90e23a11))
* env vars ([e4e6886](https://github.com/magebase/base-infra/commit/e4e68865a29eb3f00562e3bc0a1726e115fa1eee))
* format terraform files to resolve CI formatting check ([28b8abb](https://github.com/magebase/base-infra/commit/28b8abb8a796690f72a90ef6937ce269e297bb4a))
* format Terraform files to resolve CI/CD formatting check failures ([6a6bb6c](https://github.com/magebase/base-infra/commit/6a6bb6c1b50cdeaff4b0d20825bc5428a74bcb60))
* format Terraform files with terraform fmt ([2489b75](https://github.com/magebase/base-infra/commit/2489b755ae3a68c19e9820354262d157d9f97e35))
* healthcheck ([652f421](https://github.com/magebase/base-infra/commit/652f421fcc4338760f888205020ce1a27ca054d9))
* improve destroy command ([bc02be7](https://github.com/magebase/base-infra/commit/bc02be738f7294f9b1eba133d82254e7a0423b6d))
* improve destroy command ([d1a36d3](https://github.com/magebase/base-infra/commit/d1a36d3c20c6b1db04fd96fc5b1bd2f9fba5885a))
* improve destroy command ([920cb9e](https://github.com/magebase/base-infra/commit/920cb9e983fed4d2bcd8420a8e43e778d6413816))
* infra ([2bcc023](https://github.com/magebase/base-infra/commit/2bcc023709858e3a6825ff6abc72ab28a911eab2))
* kube.tf ([46e6274](https://github.com/magebase/base-infra/commit/46e6274761cbc66c3615d2975e4116a5bfb067b4))
* main ([aeb45c0](https://github.com/magebase/base-infra/commit/aeb45c0fd03a5771c16ba7f8a94623dd4d6a8d4f))
* main ([0255cf6](https://github.com/magebase/base-infra/commit/0255cf61bb205ff09ab53fdf47771f2a4d154e70))
* main ([3ac1c12](https://github.com/magebase/base-infra/commit/3ac1c126f9334c441424d1f92b2d0f085a2844a9))
* main ([b1e2eca](https://github.com/magebase/base-infra/commit/b1e2eca5cbabbb4a8e52acc917cd790c81b080a4))
* main ([d9f18eb](https://github.com/magebase/base-infra/commit/d9f18eba77981b85a935ef3de9f0ed2a337b7f51))
* main ([8132761](https://github.com/magebase/base-infra/commit/8132761d1f6ee46fbaa7d4993b6b7d6092eefecf))
* main ([cf888f7](https://github.com/magebase/base-infra/commit/cf888f78f80c272587101661400ad26e3b3f3303))
* main ([887356a](https://github.com/magebase/base-infra/commit/887356a2ce376b92fcd6dd858c6b01b2d01e92d9))
* main ([4f23bb4](https://github.com/magebase/base-infra/commit/4f23bb4d5027b8f7a7c94f4e4d0493c4c7bb6676))
* make SARIF upload robust against Advanced Security requirements ([8e13cd1](https://github.com/magebase/base-infra/commit/8e13cd138d747576facb9941780dfa0a78f690b4))
* missing cloudflare secret ([11d614c](https://github.com/magebase/base-infra/commit/11d614ce8684ba060594b633e6bbd5bd732ef48b))
* move tests after ([40090e8](https://github.com/magebase/base-infra/commit/40090e81aa78a03fa86bd02734ff9cefc00cb30a))
* networking argocd ([1d3e017](https://github.com/magebase/base-infra/commit/1d3e017a682ed6b3d4692ab579b57eaf803900a5))
* networking.. ([7e47e4b](https://github.com/magebase/base-infra/commit/7e47e4b606e4c0223d04dfd328e2e2038ecca3ef))
* new version tf ([7e0b89e](https://github.com/magebase/base-infra/commit/7e0b89ef8c6f47fddc35822e6f6f4100a86c0504))
* old genfix, site ([14deb35](https://github.com/magebase/base-infra/commit/14deb350866bf5ec93d1983262ed952a673ef06f))
* pin kured version ([0a63519](https://github.com/magebase/base-infra/commit/0a6351964e126846e9cf3b40a2b113cd113767c3))
* pipeline ([3006fa6](https://github.com/magebase/base-infra/commit/3006fa6de65d6c289704f4bde1de1dcc63e0bc68))
* pipeline ([5c44850](https://github.com/magebase/base-infra/commit/5c44850a535e690e3af02821cc80b3bbfe37e573))
* pipeline ([c95956c](https://github.com/magebase/base-infra/commit/c95956cbb60acf0493d55f5a568c462f225e8bab))
* pipeline ([38eeb03](https://github.com/magebase/base-infra/commit/38eeb030639b387edd9c62ed020f279c1917bfd3))
* pipeline ([771fb72](https://github.com/magebase/base-infra/commit/771fb7218c824b0fe002db480cecf01ae5079fd8))
* postgres ([7357c4f](https://github.com/magebase/base-infra/commit/7357c4fc9a36e847c73e542cdaa2a41faf92b488))
* prevent kustomization hanging on load balancer ([010a31d](https://github.com/magebase/base-infra/commit/010a31d29e5f9e292cec426cb93f05720dad5ff2))
* rails deploy ([8b6a524](https://github.com/magebase/base-infra/commit/8b6a524efd0ac76df904d8c861e6bbb131345d7a))
* rails deploy ([4e14167](https://github.com/magebase/base-infra/commit/4e14167b6e3541b6195a7fa6e1963aa3006f3f7a))
* refactor barman r2 bucket to base-infrastructure ([4ee50e0](https://github.com/magebase/base-infra/commit/4ee50e0598eb261c617da565c3827ec7cb68a9ff))
* refactor dirs ([ee71100](https://github.com/magebase/base-infra/commit/ee71100347cdaa5b87bbee61112a851a4df9d57a))
* refactor workflows ([c4f199f](https://github.com/magebase/base-infra/commit/c4f199fe86c5528a51e93a3d7bb47657917af2d4))
* refactor workflows ([1428ff5](https://github.com/magebase/base-infra/commit/1428ff5446765a3d115a7bf35658d1a64b6cc0c3))
* refactor workflows ([442dfdc](https://github.com/magebase/base-infra/commit/442dfdccf94348c76642d96678d5f471df05bb64))
* refactor workflows ([6f322d8](https://github.com/magebase/base-infra/commit/6f322d8eed161797ab894342ce082788a6f29aae))
* remove ArgoCD installation from extra-manifests ([bcf6ceb](https://github.com/magebase/base-infra/commit/bcf6cebeb46e5dca0f5adbaf1d6452c4e333a9e2))
* remove ARGOCD_ADMIN_PASSWORD reference from kustomization ([80eb536](https://github.com/magebase/base-infra/commit/80eb536dbb4423e094dde0ec5944c90e3fe83c75))
* remove GENFIX_TARGET_REVISION and SITE_TARGET_REVISION environment variables ([7aad62c](https://github.com/magebase/base-infra/commit/7aad62cef7c8ca57fabdcc4385b12263b25dd01b))
* remove global namespace from kustomization.yaml.tpl ([c4c0119](https://github.com/magebase/base-infra/commit/c4c011938bb82d6baa3b43d00217b2208c9b21b2))
* remove ingress deployment ([2c84279](https://github.com/magebase/base-infra/commit/2c8427945d517c054ca85545cfbef2f7512e4f39))
* Remove rendered .yaml files from extra-manifests directory ([2ac10a2](https://github.com/magebase/base-infra/commit/2ac10a25fd29d80a88275c572d124a5b6c101bce))
* remove terraform_docs hook to prevent pre-commit failures ([326e143](https://github.com/magebase/base-infra/commit/326e1430f2d34e4c51e92c460e509fc89085d9f5))
* replace ${DOMAIN} placeholder with valid hostname in ingress ([21b00e9](https://github.com/magebase/base-infra/commit/21b00e91e3ea110bfb0d9b8068e4575964f99729))
* resolve all RuboCop and Prettier offenses ([56f1bd6](https://github.com/magebase/base-infra/commit/56f1bd61d8f99e7de2ef81b12d37dc63372fbc0f))
* resolve ArgoCD SSL error by disabling HTTPS redirection ([ae2db0b](https://github.com/magebase/base-infra/commit/ae2db0ba2758194c0fb6f48ed76b980a39fce7c1))
* resolve base-infrastructure-deploy job skipping issue ([9eebc30](https://github.com/magebase/base-infra/commit/9eebc308b9db64b0fa44678edeb14338659d1a9e))
* resolve container security scan and attestation issues ([a18346a](https://github.com/magebase/base-infra/commit/a18346a3c4eb0e63f73baac0332d581824649f36))
* Resolve cross-account access issues in org-sso ([76401e2](https://github.com/magebase/base-infra/commit/76401e2f365a1a1347dc2dbc440d15261c312d3a))
* resolve GitHub Actions workflow trigger parsing error ([913a7a7](https://github.com/magebase/base-infra/commit/913a7a706782f197b323d3a530fbef69506f6580))
* resolve Hetzner resource availability and stale plan issues ([2d3d6a6](https://github.com/magebase/base-infra/commit/2d3d6a6be6e41be9d820154a73bf68251c7a5d84))
* resolve kube-hetzner v2.18.1 compatibility issues ([2e25d08](https://github.com/magebase/base-infra/commit/2e25d081b42399298a0fb90b8065d889759ad9f5))
* resolve nat_router variable validation error in kube-hetzner v2.18.0 ([7d397c8](https://github.com/magebase/base-infra/commit/7d397c8f2ff81d443db07d26fc9f1ebefb40e584))
* resolve remaining Terraform validation errors ([9a2f7d9](https://github.com/magebase/base-infra/commit/9a2f7d9fac800319954b3e92252a33fda4e54958))
* resolve sed command error in deployment step ([30c16ff](https://github.com/magebase/base-infra/commit/30c16fff6cb1c08ce5cf4d161d83828b64898bef))
* resolve semantic-release owner/repo undefined variables ([e9b4175](https://github.com/magebase/base-infra/commit/e9b4175e1eeade55972aa2e0299b579c464b331a))
* resolve Terraform environment variable and kustomization errors ([5c76cd6](https://github.com/magebase/base-infra/commit/5c76cd674a95f01b1ce0b56ddcf7891355f2878e))
* resolve Terraform errors for GitHub Actions deployment ([e91fb5d](https://github.com/magebase/base-infra/commit/e91fb5d821fcd5707c26324151efa6f239076853))
* resolve test failures and infrastructure improvements ([f33cafb](https://github.com/magebase/base-infra/commit/f33cafb740ec58fdc0771ce64459d4d3a368a27e))
* resolve timeout command error by downgrading kube-hetzner and disabling upgrades ([3828b9f](https://github.com/magebase/base-infra/commit/3828b9f50d018fda2006dfbcbd51c39371cd7db5))
* resolve timeout command not found error in kube-hetzner ([e8f889f](https://github.com/magebase/base-infra/commit/e8f889f10b8d4ecfb99d269c6ccb566379b39eab))
* restore Docker authentication for security scan ([4166dfe](https://github.com/magebase/base-infra/commit/4166dfe33c62d90be10a935bbb350665d62b6a2d))
* restore S3 backend and fix account ID handling in CI/CD workflow ([64fe775](https://github.com/magebase/base-infra/commit/64fe775a34979653fa51bf504352ee1d8f133395))
* revert ([8488fa0](https://github.com/magebase/base-infra/commit/8488fa0deca7819e970158bf88e92018c8a883ed))
* revert site infrastructure main.tf" ([227926e](https://github.com/magebase/base-infra/commit/227926eea280a6965a605d411bfaf902b5852d5a))
* revert to Singapore location with CPX11 servers ([4604fd5](https://github.com/magebase/base-infra/commit/4604fd5efc01a9425d46c94aecd2cb47ebe89e7c))
* Simplify orphaned resources cleanup approach ([bd724d6](https://github.com/magebase/base-infra/commit/bd724d6e437428f59c22e1728b8b54f522efa3a0))
* site-infrastructure ([c7b8b74](https://github.com/magebase/base-infra/commit/c7b8b74026935c1a5b683bee2462b12045129f24))
* ssh keys ([1316f9e](https://github.com/magebase/base-infra/commit/1316f9e8592d7a5d1c3439b2960febfadc1817bc))
* ssh keys ([3624e59](https://github.com/magebase/base-infra/commit/3624e590e5436f1b537672b4a963d79187b9a1e7))
* ssh keys ([5b788ff](https://github.com/magebase/base-infra/commit/5b788ff11d18538afca798d1b80c6906b5021dbd))
* ssh keys ([1a87f00](https://github.com/magebase/base-infra/commit/1a87f00c9326c5f1decd5564ea77acd85f02ae55))
* sso pipelien ([24a29c2](https://github.com/magebase/base-infra/commit/24a29c2fa60bbfe5fcb7e10e34eb783a1603fde1))
* sso pipeline ([7ee2b0c](https://github.com/magebase/base-infra/commit/7ee2b0c917465ddcc62d1a3cb43b66721f4ca571))
* sso pipeline ([1328eb6](https://github.com/magebase/base-infra/commit/1328eb6781950ea31994b56bffde9846ac618ced))
* switch site-infrastructure from local to S3 backend ([3820dcb](https://github.com/magebase/base-infra/commit/3820dcb9e8c97d1946b8000f6520488c60cc9cf1))
* switch to stable argocd ([9008f20](https://github.com/magebase/base-infra/commit/9008f20b0b26dbbc9c6ced64add14ff1b2615bb1))
* temporarily disable DynamoDB state locking to resolve lock conflicts ([d01e038](https://github.com/magebase/base-infra/commit/d01e03804104a033cacef77b41ddc41d9387405e))
* terrafor ([95026bf](https://github.com/magebase/base-infra/commit/95026bfafb25d452f824ed962bd40d7eac8ab34e))
* terraform ([1a471d8](https://github.com/magebase/base-infra/commit/1a471d80132d115c060c0c9f8fee76a7fc4e3f9d))
* terratests ([272a713](https://github.com/magebase/base-infra/commit/272a713e5cbf2c055f7b4785483fcb2980d93d62))
* tf ([0268721](https://github.com/magebase/base-infra/commit/0268721c2eb9e356b535c5b97766caffde0c2048))
* tf version ([20c0009](https://github.com/magebase/base-infra/commit/20c000907c4af67866665307beb5637c48af6e9d))
* update aws_ses_account_id references to use environment_account_id ([8c02525](https://github.com/magebase/base-infra/commit/8c025251156f4fb5cdb241f6174d3b2e832df00e))
* update base-infra to deploy ([1075ebb](https://github.com/magebase/base-infra/commit/1075ebb34b1a76f2cfd97eaadd7e5c4226721f09))
* update base-infra to deploy ([d630475](https://github.com/magebase/base-infra/commit/d63047535ce879d87f36fad96cd5bbf5f20ef720))
* Update IngressRoute to use existing argocd-tls secret ([51699ba](https://github.com/magebase/base-infra/commit/51699ba56b9eab685d9e711e7bc299643d62829c))
* update kustomization.yaml.tpl to reference processed .yaml files ([d10a8fd](https://github.com/magebase/base-infra/commit/d10a8fdd988f1de2a9c0da12f9a483ed20ed819e))
* update kustomize overlays to use resources instead of deprecated bases; remove non-existent redis patch ([eb61a88](https://github.com/magebase/base-infra/commit/eb61a88d566a318d19eafc2b342ed6bd1e04906a))
* Update kustomize variable syntax to use curly braces ([c2e43fc](https://github.com/magebase/base-infra/commit/c2e43fcc8f4976793336eae0143cb760c8fa91ce))
* update rails deployment ([7f91d63](https://github.com/magebase/base-infra/commit/7f91d6379c1141802aae1271d2e6fa5acf237fb3))
* update to use calico ([71f62df](https://github.com/magebase/base-infra/commit/71f62dff86f009114ba722e26bbb18813a431b0c))
* use development account ID from organization module for SES ([ae6d6b7](https://github.com/magebase/base-infra/commit/ae6d6b78107330814fd48412b5a7c48dc4e9e85f))
* use domain_name variable for object storage endpoints and re-enable DynamoDB locking ([98032c7](https://github.com/magebase/base-infra/commit/98032c78960b21b3d1c5d3bce413588b70809dac))
* use npm instead of yarn ([435fa25](https://github.com/magebase/base-infra/commit/435fa256d08c9eced72e01d45f78d7fedec700f5))
* validate ([705b59e](https://github.com/magebase/base-infra/commit/705b59e2867bde22f7a10237279a1cda48f9f414))
* version ([38e5041](https://github.com/magebase/base-infra/commit/38e5041ee80a67720eacaba1314b8fef8aa59b55))
* version ([c343cde](https://github.com/magebase/base-infra/commit/c343cde9e1f68cad048ba84d3e8b086e76d8570b))
* working version ([c41c853](https://github.com/magebase/base-infra/commit/c41c853896872f195947227a3d4a0bc679583520))
* yaml ([4a6f301](https://github.com/magebase/base-infra/commit/4a6f301531d6dc607b0b407bdb53150011a09f04))


### Features

* add AASM state machine to QuoteRequest model ([c460a98](https://github.com/magebase/base-infra/commit/c460a989819bdff59facad586ad220390d176838))
* add ability to skip test job in Rails deployment workflow ([9f8c258](https://github.com/magebase/base-infra/commit/9f8c258c94f191c4efacb089fb1715309b14ab79))
* add ArgoCD Application manifests for magebase app ([ece47f6](https://github.com/magebase/base-infra/commit/ece47f64875838ee9a35f882173992e2adce772f))
* add concurrency control to all GitHub Actions workflows ([c257423](https://github.com/magebase/base-infra/commit/c257423870d96c08e460e6651de6f9e4aa3f70e8))
* add GitHub secrets support for HCLOUD_TOKEN and CLOUDFLARE_API_TOKEN ([e884561](https://github.com/magebase/base-infra/commit/e8845613c280a5c4323c194c0f4ef1483f235bc5))
* Add GitHubActionsSSORole to org-sso and complete bootstrap setup ([e5521ec](https://github.com/magebase/base-infra/commit/e5521eca36550be1b5466ac8976163d183ac251b))
* Add template processing to workflow for Cloudflare R2 integration ([643da5e](https://github.com/magebase/base-infra/commit/643da5eb229f59901bff2ef52c6eefd0a47a49c3))
* add ubicloud runner ([c19b0ea](https://github.com/magebase/base-infra/commit/c19b0eafc99361aaebfc80f589367018d96eda21))
* enable HTTPS for ArgoCD with Let's Encrypt SSL certificates ([41e715c](https://github.com/magebase/base-infra/commit/41e715c19ac805e8c73ec0b88e00708e195304c3))
* Ensure site-infrastructure only runs when unified-infrastructure succeeds for same commit ([939ab77](https://github.com/magebase/base-infra/commit/939ab77372702514e484e169030d38a9d285a0c3))
* ensure SSO is enabled and all parameters passed in env-accounts ([2b23574](https://github.com/magebase/base-infra/commit/2b23574c44bcd9c49bc44f4496e4637e3b402f2c))
* implement comprehensive end-to-end encryption for k3s cluster ([883aadb](https://github.com/magebase/base-infra/commit/883aadb8e5a0e55838d2a222f1db98f44946bb93))
* Implement PostgreSQL TLS encryption and comprehensive k3s encryption verification ([bd699d9](https://github.com/magebase/base-infra/commit/bd699d9b3cd1e65cdf968e422d144744ae7cbadb))
* implement SSL termination at load balancer for ArgoCD ([8e1936e](https://github.com/magebase/base-infra/commit/8e1936ea7d1c593a6ec8fd7e992703ff17421fc8))
* segregate environments by application and environmentalize manifests ([ba32329](https://github.com/magebase/base-infra/commit/ba32329a680fde7138f009e9737158f48bdb1e32))
* set domain for dev (dev.magebase.dev) and prod (magebase.dev) overlays ([94cbdc4](https://github.com/magebase/base-infra/commit/94cbdc4f3ae6d87b671f6d81221e97a8ea0186d6))
* update all workflows to use self-hosted runners ([f60345d](https://github.com/magebase/base-infra/commit/f60345dab5b7a6d792061844425c9bfbf1052777))
* upgrade kube-hetzner to v2.18.1 as requested ([b36cbd7](https://github.com/magebase/base-infra/commit/b36cbd793e1011c283ef8b2c68fd8492da6ccfdb))


### Performance Improvements

* optimize Docker build performance ([40faf79](https://github.com/magebase/base-infra/commit/40faf790fdb08d35bb78bed92910a3efb0d14add))
