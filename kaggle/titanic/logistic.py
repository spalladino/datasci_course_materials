import pandas as pd
import numpy as np
import csv as csv
import sys

from sklearn.linear_model import LogisticRegression


def prepare(file):
  df = pd.read_csv(file, header=0)

  df = pd.concat([df, pd.get_dummies(df['Embarked'], prefix='Embarked')], axis=1)
  df = pd.concat([df, pd.get_dummies(df['Sex'], prefix='Sex')], axis=1)
  df = pd.concat([df, pd.get_dummies(df['Pclass'], prefix='Pclass')], axis=1)

  df = df.fillna(value={'Age': df['Age'].dropna().median(), 'Fare': df['Fare'].dropna().median()})

  ids = df['PassengerId'].values
  df = df.drop(['PassengerId', 'Pclass', 'Name', 'Sex', 'Ticket', 'Cabin', 'Embarked'], axis=1)

  return (df, ids)


def train_model(train):
  df, _ids = prepare(train)
  model = LogisticRegression()
  model = model.fit(df.drop(['Survived'], axis=1).values, df['Survived'].values)

  return model


def predict(model, test):
  test_data, test_ids = prepare(test)
  output = model.predict(test_data).astype(int)
  return (output, test_ids)


def main(train, test, out):
  model = train_model(train)
  output, test_ids = predict(model, test)

  writer = csv.writer(out)
  writer.writerow(["PassengerId","Survived"])
  writer.writerows(zip(test_ids, output))


if __name__ == "__main__":
  main(sys.argv[1], sys.argv[2], sys.stdout)
