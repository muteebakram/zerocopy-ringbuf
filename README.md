# xv6-assignment3

### Ringbuf Bench file

Run rb to benchmark.

### Test Files

User Ring Buffer Testing: urbt

Kernel Ring Buffer Testing: krbt

### Output (rb)

```sh
xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$ rb
Filling buffer...10485760 bytes

Current number of ringbufs: 0
Creating new ringbuf name 'muteeb' for process 3.
Found 34 contiguous virtual pages.
Start: 0x0000003fffffd000, End: 0x0000003ffffdc000
Assigned ringbuf guard page address: 0x0000003fffffd000
Newly allocated virtual page 0. va: 0x0000003fffffc000, pa: 0x0000000085735000
Newly allocated virtual page 1. va: 0x0000003fffffb000, pa: 0x0000000085734000
Newly allocated virtual page 2. va: 0x0000003fffffa000, pa: 0x0000000085733000
Newly allocated virtual page 3. va: 0x0000003fffff9000, pa: 0x0000000085732000
Newly allocated virtual page 4. va: 0x0000003fffff8000, pa: 0x0000000085731000
Newly allocated virtual page 5. va: 0x0000003fffff7000, pa: 0x0000000085730000
Newly allocated virtual page 6. va: 0x0000003fffff6000, pa: 0x000000008572f000
Newly allocated virtual page 7. va: 0x0000003fffff5000, pa: 0x000000008572e000
Newly allocated virtual page 8. va: 0x0000003fffff4000, pa: 0x000000008572d000
Newly allocated virtual page 9. va: 0x0000003fffff3000, pa: 0x000000008572c000
Newly allocated virtual page 10. va: 0x0000003fffff2000, pa: 0x000000008572b000
Newly allocated virtual page 11. va: 0x0000003fffff1000, pa: 0x000000008572a000
Newly allocated virtual page 12. va: 0x0000003fffff0000, pa: 0x0000000085729000
Newly allocated virtual page 13. va: 0x0000003ffffef000, pa: 0x0000000085728000
Newly allocated virtual page 14. va: 0x0000003ffffee000, pa: 0x0000000085727000
Newly allocated virtual page 15. va: 0x0000003ffffed000, pa: 0x0000000085726000
Newly allocated virtual page 16. va: 0x0000003ffffec000, pa: 0x0000000085735000
Newly allocated virtual page 17. va: 0x0000003ffffeb000, pa: 0x0000000085734000
Newly allocated virtual page 18. va: 0x0000003ffffea000, pa: 0x0000000085733000
Newly allocated virtual page 19. va: 0x0000003ffffe9000, pa: 0x0000000085732000
Newly allocated virtual page 20. va: 0x0000003ffffe8000, pa: 0x0000000085731000
Newly allocated virtual page 21. va: 0x0000003ffffe7000, pa: 0x0000000085730000
Newly allocated virtual page 22. va: 0x0000003ffffe6000, pa: 0x000000008572f000
Newly allocated virtual page 23. va: 0x0000003ffffe5000, pa: 0x000000008572e000
Newly allocated virtual page 24. va: 0x0000003ffffe4000, pa: 0x000000008572d000
Newly allocated virtual page 25. va: 0x0000003ffffe3000, pa: 0x000000008572c000
Newly allocated virtual page 26. va: 0x0000003ffffe2000, pa: 0x000000008572b000
Newly allocated virtual page 27. va: 0x0000003ffffe1000, pa: 0x000000008572a000
Newly allocated virtual page 28. va: 0x0000003ffffe0000, pa: 0x0000000085729000
Newly allocated virtual page 29. va: 0x0000003ffffdf000, pa: 0x0000000085728000
Newly allocated virtual page 30. va: 0x0000003ffffde000, pa: 0x0000000085727000
Newly allocated virtual page 31. va: 0x0000003ffffdd000, pa: 0x0000000085726000
Newly allocated book page. va: 0x0000003ffffdc000, pa: 0x0000000085725000
Copyout addr to userspace: 0x0000003fffffc000
Successfully created ringbuf 0 of name 'muteeb'.

Current number of ringbufs: 1
Appending to ringbuf name 'muteeb' to process 4.
Found 34 contiguous virtual pages.
Start: 0x0000003fffffd000, End: 0x0000003ffffdc000
Assigned ringbuf guard page address: 0x0000003fffffc000
Reallocated virtual page 0. va: 0x0000003fffffb000, pa: 0x0000000085735000
Reallocated virtual page 1. va: 0x0000003fffffa000, pa: 0x0000000085734000
Reallocated virtual page 2. va: 0x0000003fffff9000, pa: 0x0000000085733000
Reallocated virtual page 3. va: 0x0000003fffff8000, pa: 0x0000000085732000
Reallocated virtual page 4. va: 0x0000003fffff7000, pa: 0x0000000085731000
Reallocated virtual page 5. va: 0x0000003fffff6000, pa: 0x0000000085730000
Reallocated virtual page 6. va: 0x0000003fffff5000, pa: 0x000000008572f000
Reallocated virtual page 7. va: 0x0000003fffff4000, pa: 0x000000008572e000
Reallocated virtual page 8. va: 0x0000003fffff3000, pa: 0x000000008572d000
Reallocated virtual page 9. va: 0x0000003fffff2000, pa: 0x000000008572c000
Reallocated virtual page 10. va: 0x0000003fffff1000, pa: 0x000000008572b000
Reallocated virtual page 11. va: 0x0000003fffff0000, pa: 0x000000008572a000
Reallocated virtual page 12. va: 0x0000003ffffef000, pa: 0x0000000085729000
Reallocated virtual page 13. va: 0x0000003ffffee000, pa: 0x0000000085728000
Reallocated virtual page 14. va: 0x0000003ffffed000, pa: 0x0000000085727000
Reallocated virtual page 15. va: 0x0000003ffffec000, pa: 0x0000000085726000
Reallocated virtual page 16. va: 0x0000003ffffeb000, pa: 0x0000000085735000
Reallocated virtual page 17. va: 0x0000003ffffea000, pa: 0x0000000085734000
Reallocated virtual page 18. va: 0x0000003ffffe9000, pa: 0x0000000085733000
Reallocated virtual page 19. va: 0x0000003ffffe8000, pa: 0x0000000085732000
Reallocated virtual page 20. va: 0x0000003ffffe7000, pa: 0x0000000085731000
Reallocated virtual page 21. va: 0x0000003ffffe6000, pa: 0x0000000085730000
Reallocated virtual page 22. va: 0x0000003ffffe5000, pa: 0x000000008572f000
Reallocated virtual page 23. va: 0x0000003ffffe4000, pa: 0x000000008572e000
Reallocated virtual page 24. va: 0x0000003ffffe3000, pa: 0x000000008572d000
Reallocated virtual page 25. va: 0x0000003ffffe2000, pa: 0x000000008572c000
Reallocated virtual page 26. va: 0x0000003ffffe1000, pa: 0x000000008572b000
Reallocated virtual page 27. va: 0x0000003ffffe0000, pa: 0x000000008572a000
Reallocated virtual page 28. va: 0x0000003ffffdf000, pa: 0x0000000085729000
Reallocated virtual page 29. va: 0x0000003ffffde000, pa: 0x0000000085728000
Reallocated virtual page 30. va: 0x0000003ffffdd000, pa: 0x0000000085727000
Reallocated virtual page 31. va: 0x0000003ffffdc000, pa: 0x0000000085726000
Re-allocated book page for ringbuf 'muteeb'. va: 0x0000003ffffdb000
Copyout addr to userspace: 0x0000003fffffb000
Successfully appended to ringbuf 'muteeb' for process 4. refcount: 2
Child completed...10485760 bytes write

Current number of ringbufs: 1
Unmapping ringbuf 1 'muteeb' from process 4. vaddr: 0x0000003ffffdc000
Unmapping ringbuf book page: 0x0000003ffffdb000
Successfully unmapped from ringbuf 'muteeb'. # ringbufs: 1, refcount: 1

Parent completed...10485760 bytes read

Current number of ringbufs: 1
Unmapping ringbuf 1 'muteeb' from process 3. vaddr: 0x0000003ffffdd000
Unmapping ringbuf book page: 0x0000003ffffdc000
Successfully deleted ringbuf 1 from ringbufs. # ringbufs: 0
Zero-copy magic ringbuf # of clocks: 1
Data validation...10485760 bytes passed!
```
