# PTYKit

This Swift package provides a Swifty interface to the `forkpty()` system call. You can use
this library to send and receive I/O to a child process through a PTY. The child process will
see the input as if it was typed by the user directly in the Terminal. This is helpful for dealing
with programs such as `ssh(1)`.

This package is based on code from [PseudoTeletypewriter.Swift](https://github.com/eonil/PseudoTeletypewriter.Swift).
As with that program, this code is licensed under MIT. See the [LICENSE](./LICENSE.txt) file for more details.
