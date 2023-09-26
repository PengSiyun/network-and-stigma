****Priject: Network and stigma
****Author:  Siyun Peng
****Date:    2023/09/26
****Version: 17
****Purpose: Data Analysis


*** Loading data

cd "C:\Users\peng_admin\OneDrive - Indiana University\GATES study\network and stigma"


***************************************************************
**# 1 data clean
***************************************************************


use "T_GATE Baseline 1 & 2 Complete_9.12.2023.dta",clear
recode d3 (9999=.) (5=1) (else=0),gen(white)
lab var white "White" 
recode d9 (9999=.) (3 5=3),gen(gender)
lab var gender "Gender" 
lab define gender 1 "Male" 2 "Female" 3 "Other"
lab values gender gender
rename d1 age
recode d11 (4/9=4), gen(edu)
lab define edu 1 "<high school" 2 "GED" 3 "High school" 4 ">high school"
lab values edu edu
recode ovd1 (0=0) (1/max=1),gen(overdose)
lab var overdose "Overdose"
rename (enactedstigma anticipatedstigma internalizedstigma) (en_stgm an_stgm in_stgm) //variable name too long


***************************************************************
**# 2 Regression
***************************************************************


eststo clear
foreach x of varlist prop_gendruguse prop_opioiduse prop_remissionsud prop_injectdrugs prop_opioidoverdose {
foreach y of varlist en_stgm an_stgm in_stgm {
eststo `y'`x'1:	reg `y' age i.white i.gender i.rural_conviction i.edu `x', vce(robust)
eststo `y'`x'2:	reg `y' age i.white i.gender i.rural_conviction i.edu c.`x'##i.idu1, vce(robust)
eststo `y'`x'3:	reg `y' age i.white i.gender i.rural_conviction i.edu c.`x'##i.overdose, vce(robust)
eststo `y'`x'4:	reg `y' age i.white i.gender i.rural_conviction i.edu networksize `x', vce(robust)
eststo `y'`x'5:	reg `y' age i.white i.gender i.rural_conviction i.edu networksize c.`x'##i.idu1, vce(robust)
eststo `y'`x'6:	reg `y' age i.white i.gender i.rural_conviction i.edu networksize c.`x'##i.overdose, vce(robust)
}
}
esttab *1 using "reg.csv", replace b(%5.3f) se(%5.3f) nogap compress nonum 
esttab *2 using "reg.csv", append b(%5.3f) se(%5.3f) nogap compress nonum 
esttab *3 using "reg.csv", append b(%5.3f) se(%5.3f) nogap compress nonum 
esttab *4 using "reg.csv", append b(%5.3f) se(%5.3f) nogap compress nonum 
esttab *5 using "reg.csv", append b(%5.3f) se(%5.3f) nogap compress nonum 
esttab *6 using "reg.csv", append b(%5.3f) se(%5.3f) nogap compress nonum 


reg an_stgm age i.white i.gender i.rural_conviction i.edu networksize c.prop_opioidoverdose##i.overdose, vce(robust)
margins i.overdose, at(prop_opioidoverdose=(0(.1)1))
marginsplot, tit("") ytit("Anticipated Stigma") xtit("Proportion of network who experienced an overdose") recastci(rarea) ciopt(color(%30)) 
graph export "interaction.tif", replace



