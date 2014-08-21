import pandas as pd
import numpy as np
import csv as csv
import sys

from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import PolynomialFeatures


def prepare(file, survived_info=True):
  df = pd.read_csv(file, header=0)

  df = pd.concat([df, pd.get_dummies(df['Embarked'], prefix='Embarked')], axis=1)
  df = pd.concat([df, pd.get_dummies(df['Sex'], prefix='Sex')], axis=1)
  df = pd.concat([df, pd.get_dummies(df['Pclass'], prefix='Pclass')], axis=1)

  df = df.fillna(value={'Age': df['Age'].dropna().median(), 'Fare': df['Fare'].dropna().median()})

  survived = None
  if survived_info:
    survived = df['Survived'].values
    df = df.drop(['Survived'], axis=1)

  ids = df['PassengerId'].values
  df = df.drop(['PassengerId', 'Pclass', 'Name', 'Sex', 'Ticket', 'Cabin', 'Embarked'], axis=1)

  poly = PolynomialFeatures(interaction_only=True)
  polydata = poly.fit_transform(df)

  cols = np.hstack((['1s'], df.columns, [None]*(polydata.shape[1] - len(df.columns) -1)))
  polydf = pd.DataFrame.from_records(polydata, columns=cols)

  if survived_info: polydf['Survived'] = survived

  return (polydf, ids)


def train_model(train):
  df, _ids = prepare(train)
  model = LogisticRegression()
  model = model.fit(df.drop(['Survived'], axis=1).values, df['Survived'].values)

  return model


def predict(model, test):
  test_data, test_ids = prepare(test, survived_info=False)
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
