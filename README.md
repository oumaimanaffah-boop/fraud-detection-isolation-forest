# Détection de fraude bancaire par Machine Learning (Isolation Forest)

Détection d'anomalies non supervisée sur des transactions par carte bancaire, réalisée en R.

## Objectif
Repérer les transactions frauduleuses dans un jeu de données très déséquilibré, avec l'algorithme Isolation Forest.

## Données
Jeu de données Kaggle « Credit Card Fraud Detection » (ULB) : https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud
- 284 807 transactions bancaires
- 0,17 % de fraudes (déséquilibre de 578 pour 1)

Le jeu de données complet (143 Mo) est trop volumineux pour ce dépôt. Un échantillon de démonstration (`creditcard_sample.csv`, 4 992 transactions dont les 492 fraudes) est fourni pour tester le script. La part de fraudes y est volontairement plus élevée (environ 10 %), donc les résultats diffèrent de ceux du rapport, obtenus sur le jeu de données complet. Pour relancer le code, adapte le chemin du fichier dans le script.

## Méthode
- Prétraitement : suppression de 1 081 doublons, standardisation (z-score) des variables Amount et Time, analyse exploratoire (distributions, corrélations)
- Modélisation : Isolation Forest
- Calibrage du seuil de décision par une analyse de sensibilité sur la précision, le rappel et le F1

## Résultats
Les résultats détaillés (précision, rappel et F1 selon le seuil) sont présentés dans le rapport.

## Contenu du dépôt
- `script Banking fraud detection.R` : script R (prétraitement, modélisation, évaluation)
- `Banking_Fraud_Detection.pdf` : rapport complet du projet
- `creditcard_sample.csv` : échantillon de démonstration (4 992 transactions, dont les 492 fraudes)

## Outils
R (isotree)

## Auteure
Oumaima Naffah, Master Économie Appliquée et Data Science, FSJES Meknès (Université Moulay Ismail)
