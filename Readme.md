Kodlar `Sigasi VHDL Plugin` ile `Eclipse IDE` üzerinde yazılmıştır. Simulator olarak `ISE Simulator (ISim)` kullanılmıştır. Komutlarla alakalı olarak *Komutlar.html* dosyasından ayrıntılı bilgi edinilebilir. 

Shifter.vhd isminde özel bir dosya yok. Shift işlemleri için main içinde gerekli yerlerde `&`(concatenation) operatörü kullanılmıştır.

# Simulasyon Testleri

### Komut 1
```vhdl
add $s1, $s2, $s3  // (add $17, $18, $19)
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Çalıştırılmak istenen komut(binary) :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;000000 10010 10011 10001 00000 100000 <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Komut sonrası oluşması gereken durum :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -	Komut sonrası Reg(17) içindeki değer Reg(18) ile Reg(19) un toplamı olmalıdır. 

![Komut 1](/images/1.png)

**Girilen komutlar** <br/>
**ISim>** put reg(18) 00000000000000000000100000100000 <br/>
put reg(19) 00000000000000000000100000100000 <br/>
put pc 00000000000000000000000000000001 <br/>
put ir 00000010010100111000100000100000 <br/>
**ISim> ISim> ISim> ISim>** run <br/>
**ISim>** show value PC <br/>
00000000000000000000000000000101 <br/>
**ISim>** show value Reg(17) <br/>
00000000000000000001000001000000 <br/>
**ISim>** show value Reg(18) <br/>
00000000000000000000100000100000 <br/>
**ISim>** show value Reg(19) <br/>
00000000000000000000100000100000 <br/> 

**Sonuç** <br/>
Görüldüğü üzere PC ın eski değeri 1 iken yeni değeri 5 oldu. <br/>
Reg(17) in değeri de Reg(18) ve Reg(19)’un toplamı olarak değişti. <br/>

### Komut 2
jalr $s4, $s5 // (jalr $20, $21) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Çalıştırılmak istenen komut(binary) :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;000000 10101 00000 10100 00000 001001 <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Komut sonrası oluşması gereken durum :**  <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-	Komut sonrası bir sonraki komutun  adresi(PC + 4) Reg(20) de saklanmalı ve  PC un yeni değeri Reg(21)’in içindeki değer olmalıdır. <br/>

![Komut 2](/images/2.png)

**ISim>** put pc 00000000000000000000000000001010 <br/>
put reg(21) 01010001011110100000000000001000 <br/>
put ir 00000010101000001010000000001001 <br/>
**ISim> ISim> ISim>** run <br/>
**ISim>** show value reg(20) <br/>
00000000000000000000000000001110 <br/>
**ISim>** show value reg(21) <br/>
01010001011110100000000000001000 <br/>
**ISim>** show value pc <br/>
01010001011110100000000000001000 <br/>

### Komut 3.  
lw $s4, 2($s5) // (lw $20, 2($21)) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Çalıştırılmak istenen komut(binary) :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;100011 10101 10100 0000000000000010 <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Komut sonrası oluşması gereken durum :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-	Reg(20) nin değeri MEM(Reg(21) +2) olması lazım. PC ın da 4 artması lazım. <br/>

![Komut 3](/images/3.png)

**ISim>** put pc 00000000000000000000000000000010 <br/>
put reg(21) 00000000000000000000000000000111 <br/>
put mem(9) 00000000000000000000110000000000 <br/>
put ir 10001110101101000000000000000010 <br/>
**ISim> ISim> ISim> ISim>** run <br/>
**ISim>** show value reg(20) <br/>
00000000000000000000110000000000 <br/>
**ISim>** show value pc <br/>
00000000000000000000000000000110 <br/>

**Sonuç** <br/>
Komut reg(21) in değeri olan 7 ile 2 yi toplayıp Mem(9) bellek adresine erişiyor. Mem(9) daki adresi bizim beklediğimiz şekilde reg(20) ye atıyor.

### Komut 4.  
balmn $s4, 2($s5) // (balmn $20, 2($21)) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Çalıştırılmak istenen komut(binary) :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;010111 10101 10100 0000000000000010 <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Komut sonrası oluşması gereken durum :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-	Z = 0 olması durumunda PC + 4, Reg(20)’de saklanacak. <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-	PC ın yeni değeri MEM(Reg(21) + 2) bellek adresindeki değer olacak. <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-	Z = 1 durumda sadece PC 4 artacak. <br/>

![Komut 4](/images/4.png)

**ISim>** put sr(3) 0 <br/>
put pc 00000000000000000000000000000010 <br/>
put reg(21) 00000000000000000000000000000111 <br/>
put mem(9) 00000000000000000000110000000000 <br/>
put ir 01011110101101000000000000000010 <br/>
**ISim> ISim> ISim> ISim> ISim>** run <br/>
**ISim>** show value reg(20) <br/>
00000000000000000000000000000110 <br/>
**ISim>** show value pc <br/>
00000000000000000000110000000000 <br/>

**ISim>** put pc 00000000000000000000000000000010 <br/>
put sr(3) 1 <br/>
**ISim>** put ir 01011110101101000000000000000010 <br/>
**ISim> ISim>** run <br/>
**ISim>** show value pc <br/>
00000000000000000000000000000110 <br/>

### Komut 5
j label  <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Çalıştırılmak istenen komut(binary) :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;000010 00111111000000000000000010 <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**Komut sonrası oluşması gereken durum :** <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- PC ın yeni değeri 00000011111100000000000000001000 (PC[31:28] || Imm26 || 00) olmalı. <br/>

![Komut 5](/images/5.png)

**ISim>** put pc 00000000000000000000000000000010 <br/>
put ir 00001000111111000000000000000010 <br/>
**ISim> ISim>** run <br/>
**ISim>** show value pc <br/>
00000011111100000000000000001000 <br/>



 
