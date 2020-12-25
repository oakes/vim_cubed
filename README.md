## Vim³

Most people use vim in two stupid dimensions.

But not me.

I use it in three:

<p align="center">
  <img src="vim3.gif" >
</p>

To run it, [install Nim](https://nim-lang.org/install.html), and from this repo do:

```bash
$ nimble run vim3
```

Once you're ready to start using it as your main editor, do:

```bash
$ nimble install paravim
$ nimble install
```

As long as `~/.nimble/bin` is on your `PATH`, you will now be able to open files like this:

```bash
$ vim3 path/to/myfile.txt
```

## Q & A

### How do I acquire your power?

It's not that hard.

### How do I stop the cube from spinning

Don't.

### I don't even have vim installed, how is this possible?

It's using [paravim](https://github.com/paranim/paravim) which has a real copy of vim built in.

### Which OS does it work on?

Pretty much all of them.

### Why can't I run it on linux?

Could be you need opengl libraries, try running:
```bash
$ sudo apt install xorg-dev libgl1-mesa-dev
```

You might also need to run `sudo apt install libtinfo5`

### I use arch btw

Try this: 
```bash
$ sudo ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
```
