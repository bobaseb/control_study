#!/usr/bin/r

#system("clear")
rm(list=ls())
#options(warn=1)  # print warnings as they occur
#options(warn=2)  # treat warnings as errors

library(lme4)

trialData <- "filename here
d <- read.csv(trialData)

#d$condition[d$condition==-1]=0

#d = d[d$condition == -1,] #losses
d = d[d$condition == 1,] #gains

fm7 <- glmer(response ~ ev #+ guessAcc #+ condition #+ experiment 
             + (1 | sub) + (0 + ev |  sub),
             #+(0+condition|sub)
             #+ (0 + guessAcc |  sub),
             REML=FALSE,
             data=d, family=binomial (link="logit"))


cat("\n")
cat("\nev")
cat("\n=======================\n")
#compare(fm7, update(fm7, .~. - n_reviews), FALSE)
fm5 <- update(fm7, .~. - ev)
nReviews1 <- anova(fm7, fm5, test="Chisq")
cat("slope intercept ") 
cat(fixef(fm7)[1])
cat("\n")
cat("slope beta ") 
cat(fixef(fm7)[2])
cat("\n")
cat("chi-square ")
cat(nReviews1$Chisq[2])
cat("\n")
cat("beta p-value ")
cat(nReviews1$Pr[2])


cat("\n")
cat("\nguessAcc")
cat("\n=======================\n")
#compare(fm7, update(fm7, .~. - n_reviews), FALSE)
fm5 <- update(fm7, .~. - guessAcc)
nReviews2 <- anova(fm7, fm5, test="Chisq")
cat("\n")
cat("slope beta ") 
cat(fixef(fm7)[3])
cat("\n")
cat("chi-square ")
cat(nReviews2$Chisq[2])
cat("\n")
cat("beta p-value ")
cat(nReviews2$Pr[2])

cat("\n")
cat("\ncondition")
cat("\n=======================\n")
#compare(fm7, update(fm7, .~. - n_reviews), FALSE)
fm5 <- update(fm7, .~. - condition)
nReviews2 <- anova(fm7, fm5, test="Chisq")
cat("\n")
cat("slope beta ") 
cat(fixef(fm7)[4])
cat("\n")
cat("chi-square ")
cat(nReviews2$Chisq[2])
cat("\n")
cat("beta p-value ")
cat(nReviews2$Pr[2])

cat("\n")
cat("\nexperiment")
cat("\n=======================\n")
fm5 <- update(fm7, .~. - experiment)
nReviews2 <- anova(fm7, fm5, test="Chisq")
cat("\n")
cat("slope beta ") 
cat(fixef(fm7)[5])
cat("\n")
cat("chi-square ")
cat(nReviews2$Chisq[2])
cat("\n")
cat("beta p-value ")
cat(nReviews2$Pr[2])

relgrad <- with(fm7@optinfo$derivs,solve(Hessian,gradient))
max(abs(relgrad))


#write.csv(coef(fm7)$sub,'Coefs.csv')
