# Develop.md

## Releases

1. Make release brach `git-flow release start x.x.x`
2. Search find/replace current version in XCode project
3. Update `CHANGELOG.md`
4. Run swift lint autocorrect `make autocorrect`
5. Change version in `jazzy.yml`
6. Run `make jazzy`
7. Commit changes.
8. Create GitHub release
9. Create CocoaPods release
   1.  ` pod lib lint`
10. Finish release
    1.  `git-flow release finish x.x.x`
    2.  `git push --tags`
11. Public CocoaPod release
    1.  `pod trunk push`
