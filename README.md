# yogi

[![pipeline status](https://gitlab.com/nickdonnelly/yogi/badges/master/pipeline.svg)](https://gitlab.com/nickdonnelly/yogi/commits/master)


`yogi` is a command line tool to easily manage different configuration environments. Want to only load your vim bindings for ruby if you're working on a ruby project, but your C bindings when you're working in C? Maybe you have different configurations for bash. You can change those too. This is what `yogi` is for. No more need to create separate users for different environments.

## Installation

There are binaries [here](https://gitlab.com/nickdonnelly/yogi/-/archive/release-0.1.0/yogi-release-0.1.0.zip). Simply extract the zip and put the binary in `/usr/local/bin`:

```bash
unzip yogi-release-0.1.0.zip
sudo mv ./yogi-release-0.1.0/yogi /usr/local/bin
rm -rf yogi.tar.gz yogi-release-0.1.0
```

## Usage

By default, a configuration will be created if one doesn't exist on first use. This configuration
is called "default".

You can add things to the currently selected config with `yogi add [file] [file] [file]...`. Likewise, remove with `yogi remove[file] [file] [file]...`. `yogi a` and `yogi r` do the same.

List the configs with `yogi show` and show the contents of a specific config with `yogi show [config_name]`.

Create new configs with `yogi new [name]` and switch to them with `yogi switch [name]`. Make sure that you save any changes you've made to the current config before you switch, or they'll be lost.

Yogi comes with some rudimentary version control. Whenever you add, remove, or change files in the configuration, commits are made. You can see these with `yogi h[ist]`, and you can revert the changes with `yogi revert [commit_hash]`.

### Examples

![example-1](https://i.imgur.com/Tfmjkrl.png)

![example-2](https://i.imgur.com/0tJezkF.png) ![example-revert](https://i.imgur.com/Z6NVRfR.png)


## Running tests

Simply run `crystal spec` from the repository's top level directory. There's already some test data in the repository that the tests are configured to use.

## Contributing

If you're looking at this on Github, this is a mirror. The [primary repository](https://gitlab.com/nickdonnelly/yogi) for this is on Gitlab. That's where you should contribute.

1. Fork it ( https://gitlab.com/nickdonnelly/yogi/forks/new )
2. Create your feature branch (git checkout -b my-new-feature)
3. *Write tests*
3. Commit your changes
4. Push to the branch
5. Create a new pull request

## FAQ

> Why is it called yogi?

No reason.

## Contributors

- [[nickdonnelly]](https://github.com/nickdonnelly) Nick Donnelly - creator, maintainer, nick@donnelly.cc
