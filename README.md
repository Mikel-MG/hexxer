# Hexxer

A minimal tool written in Zig to encode and decode ASCII text to and from hexadecimal.

The aim of this project is simply to provide a minimal illustrative example of how to implement basic Zig functionality (flow control, imports, testing, allocators...). I am aware that there *much* better (and easier!) ways of implementing such an encoder, but I wanted to explore the language features.

**Warning!**: This is my first foray into the Zig programming language, so the code is probably atrocious. I *feel* that I don't quite get the design philosophy of the language, and I intend to update the repository as (if) I learn more about it. 


# Building

I am using Zig version `0.16.0-dev.1484+d0ba6642b`

```shell
# build the binaries
zig build

# run the tests
zig build test --summary all
```


# Usage

The build script (`build.zig`) produces three binaries, of which `hexxer` is the relevant one.

`hexxer` can encode (`-e`) or decode (`-d`) string text

```shell
$ hexxer -e "hello there"
68656c6c6f207468657265

$ hexxer -d "68656c6c6f207468657265"
hello there
```


Thanks to the shell powers, we can even pipe text directly from files!<br>
NOTE: If the file contains newline characters, your computer will be sad

```shell
$ hexxer -e "$(cat samples/dant.txt)"
41682c206974206973206861726420746f20737065616b206f662077686174206974207761732c20746861742073617661676520666f726573742c2064656e736520616e6420646966666963756c742c7768696368206576656e20696e20726563616c6c2072656e657773206d7920666561723a20736f2062697474657220e2809420646561746820697320686172646c79206d6f726520736576657265212042757420746f20726574656c6c2074686520676f6f6420646973636f76657265642074686572652c2049e280996c6c20616c736f2074656c6c20746865206f74686572207468696e67732049207361772e20492063616e6e6f7420636c6561726c792073617920686f7720492068616420656e74657265642074686520776f6f643b20492077617320736f2066756c6c206f6620736c656570206a7573742061742074686520706f696e742077686572652049206162616e646f6e656420746865207472756520706174682e20427574207768656e2049e280996420726561636865642074686520626f74746f6d206f6620612068696c6c20e2809420697420726f736520616c6f6e672074686520626f756e64617279206f66207468652076616c6c6579207468617420686164206861726173736564206d79206865617274207769746820736f206d756368206665617220e280942049206c6f6f6b6564206f6e206869676820616e6420736177206974732073686f756c6465727320636c6f7468656420616c7265616479206279207468652072617973206f6620746861742073616d6520706c616e65742077686963682073657276657320746f206c656164206d656e20737472616967687420616c6f6e6720616c6c20726f6164732e
```

```shell
$ hexxer -d "$(cat samples/dant_encoded.txt)"
Ah, it is hard to speak of what it was, that savage forest, dense and difficult,which even in recall renews my fear: so bitter — death is hardly more severe! But to retell the good discovered there, I’ll also tell the other things I saw. I cannot clearly say how I had entered the wood; I was so full of sleep just at the point where I abandoned the true path. But when I’d reached the bottom of a hill — it rose along the boundary of the valley that had harassed my heart with so much fear — I looked on high and saw its shoulders clothed already by the rays of that same planet which serves to lead men straight along all roads.
```


# Limitations

`hexxer` maps ASCII printable characters (character code 32-127) to hexadecimal digits. The numeric range is convenient, because we can assume that we need two hexadecimal characters to represent each ASCII character, making parsing very easy. The downside is that using any other characters, such as newline (`\n`), or any non-standard characters, will result in erroneous output or a catastrophic failure.

# Future work

I am not quite sure whether all the allocators are properly freed after being used. In my testing, I was able to remove some of the `defer` statements with no apparent effect. I wonder if using different allocators or better testing I would be able to detect (and fix) memory leaks. 

At some point I would like to add support for more characters, such as newlines.


# References

* https://ziglang.org/learn/
* https://pedropark99.github.io/zig-book/

(both excellent resources to learn Zig; do not blame THEM for my mistakes)
