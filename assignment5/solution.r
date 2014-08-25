# Step 1: Read and summarize the data
seaflow = read.csv(file="seaflow_21min.csv")
summary(seaflow)

 #    file_id           time          cell_id            d1              d2          fsc_small        fsc_perp        fsc_big            pe          chl_small        chl_big           pop
 # Min.   :203.0   Min.   : 12.0   Min.   :    0   Min.   : 1328   Min.   :   32   Min.   :10005   Min.   :    0   Min.   :32384   Min.   :    0   Min.   : 3485   Min.   :    0   crypto :  102
 # 1st Qu.:204.0   1st Qu.:174.0   1st Qu.: 7486   1st Qu.: 7296   1st Qu.: 9584   1st Qu.:31341   1st Qu.:13496   1st Qu.:32400   1st Qu.: 1635   1st Qu.:22525   1st Qu.: 2800   nano   :12698
 # Median :206.0   Median :362.0   Median :14995   Median :17728   Median :18512   Median :35483   Median :18069   Median :32400   Median : 2421   Median :30512   Median : 7744   pico   :20860
 # Mean   :206.2   Mean   :341.5   Mean   :15008   Mean   :17039   Mean   :17437   Mean   :34919   Mean   :17646   Mean   :32405   Mean   : 5325   Mean   :30164   Mean   : 8328   synecho:18146
 # 3rd Qu.:208.0   3rd Qu.:503.0   3rd Qu.:22401   3rd Qu.:24512   3rd Qu.:24656   3rd Qu.:39184   3rd Qu.:22243   3rd Qu.:32416   3rd Qu.: 5854   3rd Qu.:38299   3rd Qu.:12880   ultra  :20537
 # Max.   :209.0   Max.   :643.0   Max.   :32081   Max.   :54048   Max.   :54688   Max.   :65424   Max.   :63456   Max.   :32464   Max.   :58675   Max.   :64832   Max.   :57184



# Step 2: Split the data into test and training sets
library(caret)
trainIndex <- createDataPartition(seaflow$pop, p = .8, list = FALSE)
train = seaflow[trainIndex,]
test = seaflow[-trainIndex,]
summary(train)

 #    file_id           time          cell_id            d1              d2          fsc_small        fsc_perp        fsc_big            pe          chl_small        chl_big           pop
 # Min.   :203.0   Min.   : 12.0   Min.   :    0   Min.   : 1328   Min.   :   32   Min.   :10005   Min.   :    0   Min.   :32384   Min.   :    0   Min.   : 3675   Min.   :    0   crypto :   82
 # 1st Qu.:204.0   1st Qu.:174.0   1st Qu.: 7468   1st Qu.: 7328   1st Qu.: 9632   1st Qu.:31348   1st Qu.:13512   1st Qu.:32400   1st Qu.: 1632   1st Qu.:22531   1st Qu.: 2816   nano   :10159
 # Median :206.0   Median :361.0   Median :14990   Median :17680   Median :18512   Median :35483   Median :18083   Median :32400   Median : 2418   Median :30528   Median : 7744   pico   :16688
 # Mean   :206.2   Mean   :341.3   Mean   :14981   Mean   :17030   Mean   :17444   Mean   :34930   Mean   :17657   Mean   :32405   Mean   : 5330   Mean   :30176   Mean   : 8346   synecho:14517
 # 3rd Qu.:208.0   3rd Qu.:502.0   3rd Qu.:22370   3rd Qu.:24512   3rd Qu.:24656   3rd Qu.:39176   3rd Qu.:22237   3rd Qu.:32416   3rd Qu.: 5875   3rd Qu.:38275   3rd Qu.:12880   ultra  :16430
 # Max.   :209.0   Max.   :643.0   Max.   :32081   Max.   :54048   Max.   :54688   Max.   :65424   Max.   :63456   Max.   :32464   Max.   :58267   Max.   :64832   Max.   :57184



# Step 3: Plot the data
library(ggpplot2)
qplot(data=seaflow, x=pe, y=chl_small, color=pop)
ggsave('step3.png')



# Step 4: Train a decision tree.
library(rpart)
fol <- formula(pop ~ fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small)
treemodel <- rpart(fol, method="class", data=train)
print(treemodel)

# n= 57876

# node), split, n, loss, yval, (yprob)
#       * denotes terminal node

#  1) root 57876 41188 pico (0.0014 0.18 0.29 0.25 0.28)
#    2) pe< 5001.5 42119 25509 pico (0 0.22 0.39 0 0.38)
#      4) chl_small< 32305.5 18416  3251 pico (0 0.00022 0.82 0 0.18) *
#      5) chl_small>=32305.5 23703 10751 ultra (0 0.39 0.061 0 0.55)
#       10) chl_small>=41286.5 8278  1037 nano (0 0.87 0.00012 0 0.13) *
#       11) chl_small< 41286.5 15425  3509 ultra (0 0.13 0.094 0 0.77) *
#    3) pe>=5001.5 15757  1240 synecho (0.0052 0.054 0.005 0.92 0.015)
#      6) chl_small>=38276 1036   208 nano (0.079 0.8 0 0.057 0.065) *
#      7) chl_small< 38276 14721   263 synecho (0 0.0014 0.0053 0.98 0.011) *




# Step 5: Evaluate the decision tree on the test data.
treepred = predict(treemodel, test, type="class")
sum(test$pop == treepred) / length(test$pop)

# 0.8537361



# Step 6: Build and evaluate a random forest.
library(randomForest)
forestmodel <- randomForest(fol, data=train)
forestpred = predict(forestmodel, test, type="class")
sum(test$pop == forestpred) / length(test$pop)

# 0.9194719

importance(forestmodel)

#           MeanDecreaseGini
# fsc_small        4348.5377
# fsc_perp         3223.2568
# fsc_big           309.0717
# pe              14280.2350
# chl_big          7638.6256
# chl_small       13167.6783



# Step 7: Train a support vector machine model and compare results.
library(e1071)
svmmodel <- svm(fol, data=train)
svmpred = predict(svmmodel, test, type="class")
sum(test$pop == svmpred) / length(test$pop)

# 0.9198175



# Step 8: Construct confusion matrices
table(pred = svmpred, actual = test$pop)

#          actual
# pred      crypto nano pico synecho ultra
#   crypto      17    1    0       0     0
#   nano         1 2228    0       0   160
#   pico         0    0 4041       7   543
#   synecho      2    3   20    3620     3
#   ultra        0  307  111       2  3401

table(pred = forestpred, actual = test$pop)

#          actual
# pred      crypto nano pico synecho ultra
#   crypto      20    0    0       0     0
#   nano         0 2198    0       1   159
#   pico         0    0 4046       0   536
#   synecho      0    1    3    3627     1
#   ultra        0  340  123       1  3411

table(pred = treepred, actual = test$pop)

#          actual
# pred      crypto nano pico synecho ultra
#   crypto       0    0    0       0     0
#   nano        20 2005    0      17   313
#   pico         0    2 3808       0   823
#   synecho      0    6   14    3612    45
#   ultra        0  526  350       0  2926




# Step 9: Sanity check the data
