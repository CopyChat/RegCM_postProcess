** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* bias.Temp.summer.RRTM.gs
* 
* This script creates Modelvar's maps of the differences 
* of RegCM4 minus OBS in season 
*
* Written by Chao.TANG Sep. 2014
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*=================================================== 
* variables could be changed
*===================================== for the OBS
* 0, change the header

* 1, whether plot OBS
obs=1 

OBSproj.1='CRU'
OBSproj.1='GHCN'
OBSproj.1='ERA_Interim'
OBSproj.2='CMAP'
OBSproj.2='GPCP'
OBSproj.3='CERES'
OBSproj.4='MODIS'

GCM='HadGEM2-ES'



meanBias.1='22'
meanBias.2='22'
meanBias.3='22'
meanBias.4='0.07'
meanBias.5='0.07'
meanBias.6='0.03'

meanBias.7='0.03'
meanBias.8='0.03'
meanBias.9='0.03'
meanBias.10='0.6'
meanBias.11='0.3'
meanBias.12='-0.03'

meanBias.13='0.6'
meanBias.14='0.3'
meanBias.15='-0.03'
meanBias.16='9.4'
meanBias.17='5.5'
meanBias.18='-4'

meanBias.19='0.6'
meanBias.20='0.3'
meanBias.21='-0.03'
meanBias.22='-18'
meanBias.23='-27'
meanBias.24='-8'

* 2, obs project name for Temp, Precip, SWD, TCC:
if(OBSproj.1='ERA_Interim')
    OBSvar.1='t2m'
    OBScrs.1='1'
    OBSpls.1='-273.5'
endif
if(OBSproj.1='CRU')
    OBSvar.1='tmp'
    OBScrs.1='1'
    OBSpls.1='0'
endif
if(OBSproj.1='GHCN')
    OBSvar.1='air'
    OBScrs.1='1'
    OBSpls.1='-273.5'
endif


if(OBSproj.2='GPCP')
  OBSvar.2='precip'
  OBScrs.2='1'
  OBSpls.2='0'
endif

if(OBSproj.2='CMAP')
  OBSvar.2='precip'
  OBScrs.2='1'
  OBSpls.2='0'
endif

if(OBSproj.2='TRMM')
  OBSvar.2='hrf'
  OBScrs.2='1'
  OBSpls.2='0'
endif


if(OBSproj.3='CERES')
  OBSvar.3='rsds'
  OBSvar.3='sfc_sw_down_all'
  OBScrs.3='1'
  OBSpls.3='0'
endif


if(OBSproj.4='MODIS')
  OBSvar.4='clt'
  OBScrs.4='1'
  OBSpls.4='0'
endif


*=================================================== 

*=================================================== 

* 6, change the PATH of OBS file

*===================================== for the RegCM output
* 1, RegCM Variable to be ploted
Plotvar.1='TEMP'
Plotvar.2='Precip'
Plotvar.3='SWD'
Plotvar.4='TCC'
* 2, Varibale units to be ploted:
Unit.1='degC'
Unit.2='mm/day'
Unit.3='W/m2'
Unit.4='%'
* 3, RegCM output tag:
RegCMtag.1='SRF'
RegCMtag.2='SRF'
RegCMtag.3='SRF'
RegCMtag.4='RAD'
* 4, model ouput var name in RegCM:
Modelvar.1='s01tas'
Modelvar.2='pr'
Modelvar.3='rsds'
Modelvar.4='clt'
* 5, RegCM cross factor:
Modelcrs.1='1'
Modelcrs.2='86400'
Modelcrs.3='1'
Modelcrs.4='100'
* 6, RegCM plus factor:
Modelpls.1='-273.5'
Modelpls.2='0'
Modelpls.3='0'
Modelpls.4='1'


* 7, GCM ouput var name in RegCM:
Forcevar.1='tas'
Forcevar.2='pr'
Forcevar.3='rsds'
Forcevar.4='clt'
* 8, GCM cross factor:
Forcecrs.1='1'
Forcecrs.2='86400'
Forcecrs.3='1'
Forcecrs.4='1'
* 9, GCM plus factor:
Forcepls.1='-273.5'
Forcepls.2='0'
Forcepls.3='0'
Forcepls.4='1'

* 7, chose the Radiation Scheme:
*Radiation='CCM'
*Radiation='RRTM'

* 8, season:
season='summer'
season='winter'


monthlab.1='JFM'
monthlab.2='AMJ'
monthlab.3='JAS'
monthlab.4='OND'



Nseason=4
Nseason=3
Nseason=2
Nseason=1

*===================================== for the Plot
  biasmin.1=-5
  biasmax.1=5
  biasmin.2=-5
  biasmax.2=5
  biasmin.3=-100
  biasmax.3=100
  biasmin.4=-100
  biasmax.4=100

  obsmin.1=0
  obsmax.1=30
  obsmin.2=0
  obsmax.2=10
  obsmin.3=80
  obsmax.3=280
  obsmin.4=0
  obsmax.4=100


  couleur.1='blue->white->red'
  couleur.2='maroon->white->darkgreen'
  couleur.3='deepskyblue->white->deeppink'
  couleur.4='blue->white->crimson'

  OBScouleur.1='white->orange->red'
  OBScouleur.2='white->darkgreen'
  OBScouleur.3='white->violet->deeppink'
  OBScouleur.4='white->deepskyblue->darkblue'
*=========================================== prepare for ploting 
* 1, month label:
if(season='summer')
    monthlab='MJJASO'
  else
    monthlab='NDJFMA'
endif

* 2, obs plot title: 
OBSt=''Plotvar'_'OBSproj.j' ('Unit')'

* 3, output file name:
output='performance.RegCM_OCCIGEN+'GCM''
*output='standard'

* 4, title of the plot
TITLE='"biases vs 'OBSproj.j' of 'Plotvar'"'

*=================================================== 


******************************** to plot
  'reinit'
  'set gxout shaded'
  'set grads off'
  'set grid off'
  'set mpdset hires'
*  'set hershey off'
  'set map 1 1 8'
  'set clopts -1 -1 0.13'
*  'set lon 3 80'
*  'set lat -3 -37'
*  set strsiz hsiz <vsiz>
*  'set strsiz 1 1.6'
*  This command sets the string character size, 
*  where hsiz is the width of the characters, 
*  vsiz is the height of the characters, in virtual page inches. 
*  If vsiz is not specified, it will be set the the same value as hsiz.



  'set vpage 1 8.0 1 8'
*=================================================== 

****** open RegCM output CCM
*** sumer 2001-2005
ICTP='/Users/tang/climate/Modeling/OCCIGEN'
Forcing.1='Had_hist'
*ictp.2='CLM45_SUBEX_UW'
*ictp.2='CLM45_Micro_UW'
*ictp.4='CLM45_Micro_UW-ocn0005'
*ictp.3='CLM45_Micro_UW-ocn001'
*ictp.4='CLM45_Micro_UW-ocn002'
*ictp.5='CLM45_Micro_UW-ocn003'
*ictp.5='CLM45_Micro_UW-ocn005'
*ictp.8='CLM45_Micro_UW-ocn01'

ictpfname.1='SUBEX.Holt.CLM45.GE'
*ictpfname.2='SUBEX.UW.CLM45'
*ictpfname.1='Micro.UW.CLM45'
*ictpfname.1='Had_hist'
*ictpfname.4='Micro.UW.CLM45.ocn0005'
*ictpfname.3='Micro.UW.CLM45.ocn001'
*ictpfname.4='Micro.UW.CLM45.ocn002'
*ictpfname.5='Micro.UW.CLM45.ocn003'
*ictpfname.5='Micro.UW.CLM45.ocn005'
*ictpfname.8='Micro.UW.CLM45.ocn01'
*=================================================== 
*=================================================== 
** model
k=1; kmax=1  
*================================================== 
** variable
j=1; jmax=4
n=jmax*k+1
totalp=6*jmax
  say 'totalplot='totalp''

*=================================================== 
*=================================================== 
n=1
while(j<=jmax)
****** BEGIN read the OBS data 
    if(OBSproj.j='ERA_Interim')
      if(OBSvar.j='t2m')
        'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/ERA_Interim/ERA.t2m.mon.mean.2001-2005.swio.timmean.nc'
      else
        'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/ERA_Interim/ERA.tp.timmean.mean.2001-2005.'monthlab'.nc'
      endif
    endif
    if(OBSproj.j='GPCP')
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/GPCP/precip.mon.mean.2001-2005.swio.timmean.nc'
*      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/GPCP/precip.mon.mean.1996-2005.swio.yseasmean.nc'
    endif

    if(OBSproj.j='GHCN')
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/GHCN/GHCN.air.timmean.2001-2005.nc'
    endif
    if(OBSproj.j='CMAP')
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/CMAP/CMAP.precip.timmean.2001-2005.nc'
    endif

    if(OBSproj.j='CERES')
*      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/CERES/CERES_EBAF-TOA_Ed2.8_Subset.timmean.2001-2005.nc'
*      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/CERES/CERES_EBAF-Surface_Ed2.7_Subset.2001-2005.swio.yseasmean.nc'
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/CERES/CERES_EBAF-Surface_Ed2.7_Subset.2001-2005.swio.timmean.nc'
    endif
    if(OBSproj.j='TRMM')
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/TRMM/TRMM.hrf.timmean.mean.2001-2005.'monthlab'.nc'
    endif
    if(OBSproj.j='CRU')
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/CRU/3.20/cru_ts3.20.tmp.timmean.2001-2005.nc'
    endif
    if(OBSproj.j='MODIS')
*      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/MODIS/clt_MODIS_L3_C5_200101-200512.swio.yseasmean.nc'
      'sdfopen /Users/tang/climate/GLOBALDATA/OBSDATA/MODIS/clt_MODIS_L3_C5_200101-200512.swio.timmean.nc'
    endif
    'set dfile 1'
*    'set t 'Nseason''
    'define obsvar=('OBSvar.j')*('OBScrs.j')+('OBSpls.j')'
    'close 1'
****************** Attention *****************
****** END read the OBS data 


*************** read Forcing Model data
*************** read Forcing Model data

*=================================================== 
*    say 'open 'ICTP'/'ictpfname.k'.'RegCMtag.j'.timmean.2001-2005.nc.ctl'
    say 'sdfopen 'ICTP'/'Forcevar.j'_Amon_'GCM'_historical_r1i1p1_200101-200512.timmean.swio.nc' 
*                     rsds_Amon_GFDL-ESM2M_historical_r1i1p1_200101-200512.timmean.nc
    'sdfopen 'ICTP'/'Forcevar.j'_Amon_'GCM'_historical_r1i1p1_200101-200512.timmean.swio.nc'
    'set dfile 1'
    'set lon 3 107'
*    'set t 'Nseason''
    'q file'
    'define forcevar=('Forcevar.j')*('Forcecrs.j')+('Forcepls.j')'

*=================================================== 
**** define the differences
** RRTM-CERES
* Interplation RegCM data to 'OBSproj' GRID
* Interplation GCM data to 'OBSproj' GRID
*    'define Fvarrmp=lterp(forcevar,obsvar)'
    'define obs1rmp=lterp(obsvar,forcevar)'
    'define biasForcevar=(forcevar-obs1rmp)'

*    'display forcevar'
*    'fprintf forcevar forcevar.txt'
*    'fprintf Fvarrmp Fvarrmp.txt'
*    'fprintf obsvar obsvar.txt'
    'close 1'
*=================================================== 
*=================================================== read RegCM data:
*    say 'open 'ICTP'/'ictpfname.k'.'RegCMtag.j'.timmean.2001-2005.nc.ctl'
    say 'open 'ICTP'/'Forcing.1'.'RegCMtag.j'.mon.mean.1996-2005.swio.yseasmean.nc.ctl'
*                               GFDL_hist.RAD.timmean.1996-2005.nc 
    'open 'ICTP'/'Forcing.1'.'RegCMtag.j'.mon.mean.2001-2005.swio.timmean.nc.ctl'
*    'open 'ICTP'/'GCM'/'Forcing.1'.'RegCMtag.j'.mon.mean.1996-2005.swio.yseasmean.nc.ctl'
    'set dfile 1'
    'set lon 3 107'
    'set lat -37 -3'
*    'set t 'Nseason''
    'q file'
*    'define modvar=ave('Modelvar.j',lon=2,lon=100,lat=-3,lat=-37)'
    'define modvar=('Modelvar.j')*('Modelcrs.j')+('Modelpls.j')'
*    ('Modelcrs.j')+('Modelpls.j')'


*=================================================== 
**** define the differences
* Interplation RegCM data to 'OBSproj' GRID
* Interplation GCM data to 'OBSproj' GRID
*    'define modvarrmp=lterp(modvar,obsvar)'
    'define obs2rmp=lterp(obsvar,modvar)'
    'define biasRCMvar=(modvar-obs2rmp)'
*    'quit'

*============================ to plot OBS ( have to start from 1 )
*============================ to plot OBS ( have to start from 1 )
*============================ to plot OBS ( have to start from 1 )
*============================ to plot OBS ( have to start from 1 )
* plot num of obs
  pnobs=(j-1)*6+1
  say 'plot num of obs='pnobs''
*--------------------------------------------------- 
*    'subplot 'totalp' 'pnobs' 'jmax' -tall 1 '
    'subplot 'totalp' 'pnobs' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
*   'sel xlopts color thckns size' for the axis
*    'set strsiz 0.2 0.2'
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  say '--------OBS OBS OBS OBS--- plot number is 'pnobs''
  'run colors.gs'
  'color 'obsmin.j' 'obsmax.j' -kind 'OBScouleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd obsvar'
  'cbarn 0.6 0 5.5 1.5'
*  'drawstr -p 12 -k 5 -z 0.25 -t 'monthlab' -xo -0.3'
  'draw title 'OBSproj.j' ('Unit.j')'
  'draw ylab 5 year mean'

* ----------------------------- to draw mean bias
  'd aave(obsvar,lon=0,lon=110,lat=-37,lat=-3)'
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.pnobs' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END to plot forcing model
*  font thickness are controlled by cbarn.gs in /usr/local/grads-2.0.2/lib/scripts
*  by 'set string color <justification <thickness <rotation>>>'
*  'xcbar 0.6 0 5.5 1.5 -fw 0.15 -fh 0.18 -edge triangle -fs 2 -fo 1'

*============================ to plot forcing GCM data:
*============================ to plot forcing GCM data:
*============================ to plot forcing GCM data:
* num of forcing data map:
    m1=(j-1)*6+2
    say 'plot num of forcing data='m1''
    say '-------No. 'j' variable is 'Plotvar.j'------ plot number is 'm1''
*--------------------------------------------------- 

*    'subplot 'totalp' 'm1' 'jmax' -tall 1 '
    'subplot 'totalp' 'm1' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
    'set font 0.1 small small arial'
*   'sel xlopts color thckns size' for the axis
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  'run colors.gs'
  'color 'obsmin.j' 'obsmax.j' -kind 'OBScouleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd forcevar'
*  'd Fvarrmp'
  'draw title 'GCM' output'
  'cbarn 0.6 0 5.5 1.5'
  'draw ylab 5 years mean'
*  'drawstr -p 12 -k 5 -z 0.25 -t 'monthlab' -xo -0.3'
* ----------------------------- to draw mean bias
  'd aave(Fvarrmp,global)'
  meanbias1=sublin(result,1)
  meanbias = subwrd(meanbias1,4)
*  meanbias = math_nint(meanbias1)
*  meanbias: C_format = "%.2f"
  say 'meanbias='meanbias
*  'drawstr -p 12 -k 5 -z 0.25 -t 'meanbias' -xo -0.3 -yo -1.6 %g'
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.m1' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END to plot forcing model



*============================ to plot RegCM output

*--------------------------------------------------- 
* plot num 
    m2=(j-1)*6+3
    say 'plot num ='m2''
*--------------------------------------------------- 
    say '-------No. 'j' variable is 'Plotvar.j'------ plot number is 'm2''
*--------------------------------------------------- 

*    'subplot 'totalp' 'm2' 'jmax' -tall 1'
    'subplot 'totalp' 'm2' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
    'set font 0.1 small small arial'
*   'sel xlopts color thckns size' for the axis
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  'run colors.gs'
  'color 'obsmin.j' 'obsmax.j' -kind 'OBScouleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd modvar'
  'draw title RegCM output'
  'cbarn 0.6 0 5.5 1.5'
  'draw ylab 5 years mean'
*  'drawstr -p 12 -k 5 -z 0.25 -t 'monthlab' -xo -0.3'
* ----------------------------- to draw mean bias
  'd aave(modvar,global)'
  meanbias1=sublin(result,1)
  meanbias = subwrd(meanbias1,4)
*  meanbias = math_nint(meanbias1)
  say 'meanbias='meanbias
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.m2' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END to plot forcing model



*============================ to plot bias of Forcing data:

*--------------------------------------------------- 
* plot num 
    m3=(j-1)*6+4
    say 'plot num ='m3''
*--------------------------------------------------- 
    say '-------No. 'j' variable is 'Plotvar.j'------ plot number is 'm3''
*--------------------------------------------------- 

*    'subplot 'totalp' 'm3' 'jmax' -tall 1'
    'subplot 'totalp' 'm3' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
    'set font 0.1 small small arial'
*   'sel xlopts color thckns size' for the axis
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  'run colors.gs'
  'color 'biasmin.j' 'biasmax.j' -kind 'couleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd biasForcevar'
  'draw title 'GCM' - 'OBSproj.j''
  'cbarn 0.6 0 5.5 1.5'
  'draw ylab 5 years mean'
  'drawstr -p 12 -k 5 -z 0.25 -t 'Unit.j' -xo -0.3'
* ----------------------------- to draw mean bias
  'd aave(biasForcevar,global)'
  meanbias1=sublin(result,1)
  meanbias = subwrd(meanbias1,4)
*  meanbias = math_nint(meanbias1)
  say 'meanbias='meanbias
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.m3' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END bias of forcing data



*============================ to plot bias of RegCM output

*--------------------------------------------------- 
* plot num 
    m4=(j-1)*6+5
    say 'plot num ='m4''
*--------------------------------------------------- 
    say '-------No. 'j' variable is 'Plotvar.j'------ plot number is 'm4''
*--------------------------------------------------- 

*    'subplot 'totalp' 'm4' 'jmax' -tall 1'
    'subplot 'totalp' 'm4' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
    'set font 0.1 small small arial'
*   'sel xlopts color thckns size' for the axis
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  'run colors.gs'
  'color 'biasmin.j' 'biasmax.j' -kind 'couleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd biasRCMvar'
  'draw title RegCM - 'OBSproj.j''
  'cbarn 0.6 0 5.5 1.5'
  'draw ylab 5 years mean'
*  'drawstr -p 12 -k 5 -z 0.25 -t 'monthlab' -xo -0.3'
  'drawstr -p 12 -k 5 -z 0.25 -t 'Unit.j' -xo -0.3'
* ----------------------------- to draw mean bias
  'd aave(biasRCMvar,global)'
  meanbias1=sublin(result,1)
  meanbias = subwrd(meanbias1,4)
*  meanbias = math_nint(meanbias1)
  say 'meanbias='meanbias
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.m4' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END to plot bias of forcing model



*============================ to plot RegCM output - Forcing 

**** define the differences
* Interplation RegCM data to GCM
    'define Mvarrmp=lterp(modvar,forcevar)'
    'define biasMFvar=(Mvarrmp-forcevar)'
*--------------------------------------------------- 
* plot num 
    m5=(j-1)*6+6
    say 'plot num ='m5''
*--------------------------------------------------- 
    say '-------No. 'j' variable is 'Plotvar.j'------ plot number is 'm5''
*--------------------------------------------------- 

*    'subplot 'totalp' 'm5' 'jmax' -tall 1'
    'subplot 'totalp' 'm5' 'jmax' '
* 20=total NO. of plots; k= plot num.; 3 NO.of column

*--------------------------------------------------- 
    'set xlopts 1 4 0.15'
    'set ylopts 1 4 0.15'
    'set font 0.1 small small arial'
*   'sel xlopts color thckns size' for the axis
* string size horizental vertical' for 'monthlab'
*--------------------------------------------------- 
  'run colors.gs'
  'color 'biasmin.j' 'biasmax.j' -kind 'couleur.j''
* 'color -var biasmodvar -kind blue->white->red'
  'd biasMFvar'
  'draw title RegCM - 'GCM''
  'cbarn 0.6 0 5.5 1.5'
  'draw ylab 5 years mean'
*  'drawstr -p 12 -k 5 -z 0.25 -t 'monthlab' -xo -0.3'
* ----------------------------- to draw mean bias
  'd aave(biasMFvar,global)'
  meanbias1=sublin(result,1)
  meanbias = subwrd(meanbias1,4)
*  meanbias = math_nint(meanbias1)
  say 'meanbias='meanbias
  'drawstr -p 12 -k 5 -z 0.25 -t mean: 'meanBias.m5' -xo -0.3 -yo -1.6 %g'
*  'drawstr -p 12 -t 'monthlab.Nseason' -xo -0.3'
*============================ END to plot forcing model


  'close 1'
************** END to plot OBS
  j=j+1
endwhile





*=================================================== 
    'set vpage off'
    'save 'output''
*=================================================== 
    say 'open 'output'.eps'
    '! killapp Preview'
    '! open 'output'.eps'
