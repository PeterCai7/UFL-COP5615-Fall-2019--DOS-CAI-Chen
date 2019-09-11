Important things to show:
1. group members: Ju Cai (UFID: 9669-1796), Tianyang Chen(UFID: 4925-2917).
    steps to run our program: Exprees the zip file compression to your local directory and use shell/command prompt to enter this directory and use this command line: mix run proj1.exs 100000 200000.
2. The number of worker actors that we created: 4 worker actors.
3. Size of the work unit of each worker actor that you determined results in best performance for your implementation and an explanation on how you determined it. Size of the work unit refers to the number of sub-problems that a worker gets in a single request from the boss.
   Firstly we created 2 worker actors and each of them gets 50000 sub-problems. Then we increased worker actors from 2 to 4, since our cpu is 2 core 4 threads, the performance of CPU maintains in a stable level when we assigned more than 4 worker actors.
4. The result of running your program for: mix run proj1.exs 100000 200000.
116725 161 725
125433 231 543
133245 315 423
134725 317 425
135837 351 387
136525 215 635
146137 317 461
152685 261 585
156289 269 581
175329 231 759
180225 225 801
180297 201 897
193257 327 591
193945 395 491
197725 275 719
108135 135 801
117067 167 701
124483 281 443
126027 201 627
129775 179 725
156915 165 951
102510 201 510
105210 210 501
105750 150 705
110758 158 701
123354 231 534
126846 261 486
131242 311 422
132430 323 410
140350 350 401
145314 351 414
172822 221 782
173250 231 750
174370 371 470
182250 225 810
182650 281 650
192150 210 915
104260 260 401
105264 204 516
115672 152 761
118440 141 840
120600 201 600
125248 152 824
125460 204 615 246 510
125500 251 500
129640 140 926
135828 231 588
136948 146 938
146952 156 942
150300 300 501
152608 251 608
153436 356 431
156240 240 651
162976 176 926
163944 396 414
186624 216 864
190260 210 906
5. Report the running time for the above problem (4). The ratio of CPU time to REAL TIME tells you how many cores were effectively used in the computation. If you are close to 1 you have almost no parallelism (points will be subtracted).
   CPU time : 2.893s. REAL time: 1.168s. Ratio: 2.893/1.168 = 2.48. 
6. The largest problem you managed to solve (For example You can try finding out bigger vampire numbers than 200000). We tried to run our program in range of 200000 to 300000. And find vampire numbers larger than 200000.
205785 255 807
216733 323 671
213466 341 626
217638 321 678
226498 269 842
245182 422 581
253750 350 725
260338 323 806
263074 437 602
284598 489 582
201852 252 801
211896 216 981
215860 251 860
218488 248 881
226872 276 822
229648 248 926
233896 338 692
241564 461 524
251896 296 851
254740 470 542
262984 284 926
284760 420 678
286416 468 612
296320 320 926
7. (Optional)- You could also inspect your code with observer (using- :observer.start) and attach a screenshot of CPU utilization chart.
 