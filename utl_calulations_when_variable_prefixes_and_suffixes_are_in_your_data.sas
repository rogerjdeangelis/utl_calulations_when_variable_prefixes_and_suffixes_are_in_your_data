Calulations when variable prefixes and suffixes are in your data

PART OF the SAS/WPS paradigm shift.
Note how powerfull meta data is simplifies the datastep.
Also note the 'mon' valiable names do not appear anywhere.


github
https://tinyurl.com/ydfyd9np
https://tinyurl.com/y85mb8rz
https://github.com/rogerjdeangelis/utl_calulations_when_variable_prefixes_and_suffixes_are_in_your_data

https://tinyurl.com/y85mb8rz
https://communities.sas.com/t5/SAS-Data-Management/How-to-repeat-a-symput-function-to-multiple-observations/m-p/466145


INPUT
=====


 WORK.HAVE total obs=5                                     |  RULES
                                                           |
  ID    FLG    PFX    SFX    A_MON_B    A_MON_C    B_MON_C |   A_MON_B
                                                           |
   1     0      a      b        1          0          0    |      0    set pfx_mon_sfx=flg
                                                                       a_mon_b=0

   2     1      a      c        1          1          0    |      1
   3     0      b      c        0          1          0    |      0
   4     1      a      b        0          1          1    |      1
   5     0      b      c        0          1          0    |      0
                                                           |
                                                           |
 EXAMPLE OUTPUT                                            |

   ID    FLG    PFX    SFX    A_MON_B    A_MON_C    B_MON_C   Change to

    1     0      a      b        0          0          0      **  all 0 other results possible
    2     1      a      c        1          1          1      **  all 1 depending of fla
    3     0      b      c        0          0          0      **  all 0
    4     1      a      b        1          1          1      **  all 1
    5     0      b      c        0          0          0      **  all 0



PROCESS
=======

data want;

   * get the meta data;
   * use transpose or contents because EG server SQL dictionaries are very very slow(10 mins);

   if _n_ = 0 then do;
      %let rc=%sysfunc(dosubl('
         proc transpose data=have(obs=1 drop=id flg pfx sfx) out=havXpo(keep=_name_);
           var _all_;
         run;quit;
         proc sql;
            select
               quote(_name_)
              ,_name_
             into
               :namsq separated by ","
              ,:nams  separated by " "
            from
              havXpo
         ;quit;
      '));
   end;

   set have;

   array nams[*] &nams;
   do idx=1 to dim(nams);
       if  vname(nams[idx]) in (&namsq) then nams[idx]=flg;
   end;

   drop idx;

;run;quit;


OUTPUT
======

  WORK.WANT total obs=5

   ID    FLG    PFX    SFX    A_MON_B    A_MON_C    B_MON_C

    1     0      a      b        0          0          0
    2     1      a      c        1          1          1
    3     0      b      c        0          0          0
    4     1      a      b        1          1          1
    5     0      b      c        0          0          0

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;

    input id ( flg pfx sfx a_mon_b  a_mon_c  b_mon_c) ($2.);
    datalines;
1 0 a b 1 0 0
2 1 a c 1 1 0
3 0 b c 0 1 0
4 1 a b 0 1 1
5 0 b c 0 1 0
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process


