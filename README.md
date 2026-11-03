<div align="center">
  <img src="oumaima_fraud_detection_banner.png" alt="Infographie du projet de détection de fraude bancaire par Isolation Forest — Oumaima Naffah" width="100%" />

  <h1>Détection de fraude bancaire par Machine Learning</h1>
  <p><strong>Isolation Forest · Détection d’anomalies non supervisée · R</strong></p>
  <p>Repérer les transactions atypiques dans un jeu de données fortement déséquilibré.</p>

  ![R](https://img.shields.io/badge/Language-R-276DC3?logo=r&logoColor=white)
  ![Machine Learning](https://img.shields.io/badge/Machine%20Learning-Isolation%20Forest-7D2855)
  ![Type](https://img.shields.io/badge/Approche-Non%20supervisée-BC7890)
  [![Dataset](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)
</div>

---

## À propos du projet

Ce projet explore l’utilisation de **l’algorithme Isolation Forest** pour détecter des transactions bancaires potentiellement frauduleuses. L’objectif est d’identifier les comportements atypiques dans les paiements par carte, alors que les opérations frauduleuses représentent une part infime des transactions observées.

Le travail a été réalisé en **R**, avec le package [`isotree`](https://cran.r-project.org/package=isotree). Il comprend le prétraitement des données, l’analyse exploratoire, la modélisation et l’étude du seuil de décision.

## Objectif

Détecter les transactions susceptibles d’être frauduleuses dans un jeu de données extrêmement déséquilibré, en utilisant une méthode de détection d’anomalies non supervisée.

L’enjeu ne consiste pas seulement à repérer des observations inhabituelles : il s’agit également d’étudier l’impact du seuil retenu sur trois indicateurs essentiels — **la précision, le rappel et le score F1**.

## Jeu de données

Le projet s’appuie sur le jeu de données public **Credit Card Fraud Detection (ULB)**, disponible sur Kaggle :

[Consulter le jeu de données sur Kaggle](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)

| Caractéristique | Jeu de données complet |
|---|---:|
| Nombre de transactions | 284 807 |
| Nombre de transactions frauduleuses | 492 |
| Part des fraudes | Environ 0,17 % |
| Déséquilibre entre classes | Environ 578 transactions normales pour 1 fraude |

### Échantillon de démonstration

Le dépôt contient `creditcard_sample.csv`, un échantillon réduit de **4 992 transactions**, comprenant les **492 fraudes** du jeu de données. Il permet de tester le script sans télécharger le fichier complet, qui pèse environ 143 Mo.

> **À noter :** cet échantillon est volontairement enrichi en transactions frauduleuses (environ 10 %). Sa proportion de fraudes ne reflète donc pas celle du jeu de données complet. Les résultats obtenus avec l’échantillon peuvent différer sensiblement de ceux présentés dans le rapport, qui reposent sur le jeu de données complet.

## Méthodologie

Le projet suit les principales étapes d’un pipeline de détection d’anomalies :

1. **Prétraitement des données** — suppression de 1 081 doublons et préparation des variables.
2. **Standardisation** — transformation des variables `Amount` et `Time` à l’aide du z-score.
3. **Analyse exploratoire** — étude des distributions et des corrélations afin de mieux comprendre les données.
4. **Modélisation** — entraînement d’un modèle de détection d’anomalies basé sur **Isolation Forest**, à l’aide du package `isotree`.
5. **Calibrage du seuil** — analyse de sensibilité pour étudier l’évolution de la précision, du rappel et du score F1 selon différents seuils de décision.

### Pourquoi Isolation Forest ?

Isolation Forest est une méthode de détection d’anomalies qui cherche à isoler les observations atypiques. Elle est particulièrement intéressante dans ce contexte, où les transactions frauduleuses sont très minoritaires et où les comportements suspects ne sont pas nécessairement connus à l’avance.

## Résultats et évaluation

Le rapport présente les résultats détaillés de l’analyse de sensibilité du seuil, notamment l’évolution de :

- **Précision** : part des transactions signalées comme frauduleuses qui sont effectivement frauduleuses ;
- **Rappel** : part des fraudes réelles détectées par le modèle ;
- **Score F1** : compromis entre précision et rappel.

Les valeurs détaillées et les graphiques associés sont disponibles dans `Banking_Fraud_Detection.pdf`. Aucun score unique n’est repris ici afin de laisser les résultats tels qu’ils sont documentés dans le rapport.

## Contenu du dépôt

```text
.
├── README.md
├── oumaima_fraud_detection_banner.png
├── script Banking fraud detection.R
├── Banking_Fraud_Detection.pdf
└── creditcard_sample.csv
```

| Fichier | Description |
|---|---|
| `script Banking fraud detection.R` | Script R : prétraitement, analyse exploratoire, modélisation et évaluation. |
| `Banking_Fraud_Detection.pdf` | Rapport complet présentant la démarche et les résultats. |
| `creditcard_sample.csv` | Échantillon de démonstration de 4 992 transactions, dont 492 fraudes. |
| `oumaima_fraud_detection_banner.png` | Bannière personnalisée du projet. |

Le fichier complet `creditcard.csv` n’est pas inclus dans le dépôt en raison de sa taille (environ 143 Mo). Il peut être téléchargé depuis la page Kaggle du projet.

## Installation et utilisation

### Prérequis

- [R](https://www.r-project.org/) installé sur votre ordinateur ;
- le package R [`isotree`](https://cran.r-project.org/package=isotree) ;
- le fichier de données à utiliser : `creditcard_sample.csv` pour un test rapide, ou le jeu de données complet téléchargé depuis Kaggle.

Installer `isotree` depuis la console R :

```r
install.packages("isotree")
```

### Lancer le projet

1. Clonez ou téléchargez le dépôt.
2. Ouvrez `script Banking fraud detection.R` dans R ou RStudio.
3. Vérifiez et adaptez, dans le script, le chemin d’accès au fichier CSV choisi.
4. Exécutez le script pour lancer les étapes de prétraitement, de modélisation et d’évaluation.

**Exemple de chemin à adapter dans le script :**

```r
file_path <- "creditcard_sample.csv"
```

Le chemin exact peut varier selon l’organisation de vos fichiers et le répertoire de travail R.

## Points d’attention

- La forte rareté des fraudes rend l’évaluation délicate : l’accuracy seule ne suffit pas pour juger la qualité du modèle.
- Le seuil de décision influence directement l’équilibre entre précision et rappel ; son choix doit tenir compte du coût relatif des faux positifs et des fraudes manquées.
- Une anomalie détectée par le modèle constitue un **signal à examiner**, et non une preuve automatique de fraude.
- Pour reproduire les résultats du rapport, utilisez le jeu de données complet et le même prétraitement, plutôt que l’échantillon de démonstration.

## Outils

- **R** — environnement de programmation statistique ;
- **`isotree`** — implémentation d’Isolation Forest ;
- **Kaggle / ULB** — source du jeu de données.

## Auteure

**Oumaima Naffah**  
Master Économie Appliquée et Data Science  
FSJES Meknès — Université Moulay Ismaïl

---

<div align="center">
  <em>Analyser · Modéliser · Détecter les signaux faibles</em>
  <br />
  Projet académique — Détection de fraude bancaire par Machine Learning
</div>
