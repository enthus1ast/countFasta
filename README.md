# High performance tool to (correctly) count sequences in a fasta file.

## How to get it:

  ### build it yourself
  with Nim ( https://nim-lang.org ):

  ```
    nim c -d:release --opt:speed -d:danger --passl:-s "fastalib.nim"
  ```

  ### download prebuild binary

  - [windows](https://github.com/enthus1ast/countFasta/blob/master/fastalib.exe)

## usage:

  Count sequences in fasta files:

  ```
    fastalib.exe count -p *.fasta
    92169   tt.fasta
    737352  tt2.fasta
  ```

  Count sequences in fasta file, but also report sequences where an additional ">" is in the description.
  These lines give wrong result when just counting ">" in an editor or with grep.

  ```
    fastalib.exe report -p *.fasta
    [wrong] line:365        pos:22884       string:>sp|P14060|3BHS1_HUMAN 3 beta-hydroxysteroid dehydrogenase/Delta 5-->4-isomerase type 1 OS=Homo sapiens GN=HSD3B1 PE=1 SV=2
    [wrong] line:638        pos:39741       string:>sp|P31941|ABC3A_HUMAN DNA dC->dU-editing enzyme APOBEC-3A OS=Homo sapiens GN=APOBEC3A PE=1 SV=3
    [wrong] line:643        pos:40046       string:>sp|P31941-2|ABC3A_HUMAN Isoform 2 of DNA dC->dU-editing enzyme APOBEC-3A OS=Homo sapiens GN=APOBEC3A
    [wrong] line:648        pos:40334       string:>sp|Q8IUX4|ABC3F_HUMAN DNA dC->dU-editing enzyme APOBEC-3F OS=Homo sapiens GN=APOBEC3F PE=1 SV=3
    [wrong] line:656        pos:40816       string:>sp|Q8IUX4-2|ABC3F_HUMAN Isoform 2 of DNA dC->dU-editing enzyme APOBEC-3F OS=Homo sapiens GN=APOBEC3F
    .....
    737352  tt2.fasta
  ```
