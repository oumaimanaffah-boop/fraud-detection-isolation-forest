install.packages(c("tidyverse", "scales", "isotree",
                   "pROC", "caret", "corrplot",
                   "reshape2", "Rtsne", "gridExtra"))

library(tidyverse)
library(scales)
library(isotree)
library(pROC)
library(caret)
library(corrplot)
library(reshape2)
library(Rtsne)
library(gridExtra)
data <- read_csv("creditcard.csv")

print(paste("Number of rows    :", nrow(data)))    # 284807
print(paste("Number of columns :", ncol(data)))    # 31
glimpse(data)
missing_values <- colSums(is.na(data))
print("Missing values per column:")
print(missing_values)    # All 0
cat("Number of duplicates:", sum(duplicated(data)), "\n")  # 1081
data <- data %>% distinct()
cat("Rows after removing duplicates:", nrow(data), "\n")
data$Class <- factor(data$Class,
                     levels = c(0, 1),
                     labels = c("Normal", "Fraud"))

table_class <- table(data$Class)
prop_class  <- prop.table(table_class) * 100

print("Class distribution:")
print(table_class)      # Normal: 284315 | Fraud: 492

print("Proportions (%):")
print(round(prop_class, 4))  # 99.8273% | 0.1727%
data$Scaled_Amount <- as.numeric(scale(data$Amount))
data$Scaled_Time   <- as.numeric(scale(data$Time))
data_clean <- data %>%
  select(-Time, -Amount)

cat("Clean dataset dimensions:",
    nrow(data_clean), "x", ncol(data_clean), "\n")
# Result: 283726 x 30

head(data_clean)
p1 <- ggplot(data, aes(x = Class, fill = Class)) +
  geom_bar() +
  scale_y_log10(labels = label_number()) +
  scale_fill_manual(values = c("Normal" = "#2ecc71",
                               "Fraud"  = "#e74c3c")) +
  theme_minimal(base_size = 12) +
  labs(title    = "Transaction Class Distribution (Log Scale)",
       subtitle = paste0("Normal: ", table_class[1],
                         "  |  Fraud: ", table_class[2]),
       x = "Category",
       y = "Number of Transactions (Log)")

print(p1)
ggsave("fig01_class_distribution.png", p1,
       width = 8, height = 5, dpi = 300)
pie_data <- data.frame(
  Class      = names(prop_class),
  Proportion = as.numeric(prop_class)
)

p2 <- ggplot(pie_data, aes(x = "", y = Proportion,
                           fill = Class)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  scale_fill_manual(values = c("Normal" = "#2ecc71",
                               "Fraud"  = "#e74c3c")) +
  theme_void() +
  geom_text(aes(label = paste0(round(Proportion, 2), "%")),
            position = position_stack(vjust = 0.5),
            color = "white", size = 5) +
  labs(title = "Class Proportions (%)")

print(p2)
ggsave("fig02_pie_chart.png", p2,
       width = 6, height = 6, dpi = 300)
p3 <- ggplot(data, aes(x = Class, y = Amount, fill = Class)) +
  geom_violin(alpha = 0.7) +
  geom_boxplot(width = 0.1, fill = "white", alpha = 0.8) +
  scale_y_log10(labels = label_dollar()) +
  scale_fill_manual(values = c("Normal" = "#3498db",
                               "Fraud"  = "#e74c3c")) +
  theme_minimal(base_size = 12) +
  labs(title = "Transaction Amount Distribution by Class (Log Scale)",
       x = "Class", y = "Amount ($)")

print(p3)
ggsave("fig03_amount_by_class.png", p3,
       width = 8, height = 5, dpi = 300)
stats_by_class <- data %>%
  group_by(Class) %>%
  summarise(
    n          = n(),
    mean_amt   = round(mean(Amount), 2),
    median_amt = round(median(Amount), 2),
    sd_amt     = round(sd(Amount), 2),
    max_amt    = round(max(Amount), 2)
  )
print(stats_by_class)
p4 <- ggplot(data, aes(x = Time / 3600, fill = Class)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("Normal" = "#3498db",
                               "Fraud"  = "#e74c3c")) +
  theme_minimal(base_size = 12) +
  labs(title = "Temporal Distribution of Transactions",
       x = "Time (hours)", y = "Density")

print(p4)
ggsave("fig04_temporal_distribution.png", p4,
       width = 9, height = 4, dpi = 300)
vars_corr <- data_clean %>%
  select(V1:V10) %>%
  cor()

png("fig05_correlation_matrix.png",
    width = 900, height = 800, res = 120)
corrplot(vars_corr,
         method = "color",
         type   = "upper",
         tl.cex = 0.8,
         col    = colorRampPalette(
           c("#e74c3c", "white", "#3498db"))(200),
         title  = "Correlation Matrix — V1 to V10",
         mar    = c(0, 0, 2, 0))
dev.off()
data_long <- data_clean %>%
  select(Class, V1, V2, V3, V4, V5, V6, V7, V8) %>%
  pivot_longer(cols      = -Class,
               names_to  = "Variable",
               values_to = "Value")

p5 <- ggplot(data_long,
             aes(x = Class, y = Value, fill = Class)) +
  geom_boxplot(outlier.size = 0.3, alpha = 0.7) +
  facet_wrap(~Variable, scales = "free_y", ncol = 4) +
  scale_fill_manual(values = c("Normal" = "#3498db",
                               "Fraud"  = "#e74c3c")) +
  theme_minimal(base_size = 10) +
  labs(title = "Distribution of Variables V1–V8 by Class",
       x = "Class", y = "Value") +
  theme(legend.position = "bottom")

print(p5)
ggsave("fig06_boxplots_V1_V8.png", p5,
       width = 12, height = 7, dpi = 300)
features    <- data_clean %>%
  select(-Class) %>%
  as.data.frame()
labels_real <- ifelse(data_clean$Class == "Fraud", 1, 0)
contam_rate <- mean(labels_real)
cat("Contamination rate:", round(contam_rate * 100, 4), "%\n")
set.seed(42)
cat("Training Isolation Forest...\n")

model_if <- isolation.forest(
  data        = features,
  ntrees      = 100,   # Number of isolation trees
  sample_size = 256,   # Sub-sample size per tree
  ndim        = 1,     # Univariate splits
  nthreads    = 1      # Single thread for reproducibility
)

cat("Model trained successfully.\n")
anomaly_scores <- predict(model_if, features)

cat("--- Score Summary ---\n")
cat("Min    :", round(min(anomaly_scores), 4), "\n")
cat("Max    :", round(max(anomaly_scores), 4), "\n")
cat("Mean   :", round(mean(anomaly_scores), 4), "\n")
cat("Median :", round(median(anomaly_scores), 4), "\n")
threshold <- quantile(anomaly_scores,
                      probs = 1 - contam_rate)
cat("Decision threshold:", round(threshold, 4), "\n")
pred_factor  <- factor(
  ifelse(anomaly_scores >= threshold, "Fraud", "Normal"),
  levels = c("Normal", "Fraud"))
label_factor <- factor(
  ifelse(labels_real == 1, "Fraud", "Normal"),
  levels = c("Normal", "Fraud"))
score_df <- data.frame(
  Score = anomaly_scores,
  Class = data_clean$Class
)

p6 <- ggplot(score_df, aes(x = Score, fill = Class)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("Normal" = "#2ecc71",
                               "Fraud"  = "#e74c3c")) +
  geom_vline(xintercept = threshold,
             linetype = "dashed", color = "gray30",
             linewidth = 1) +
  theme_minimal(base_size = 12) +
  labs(title    = "Anomaly Score Distribution by Class",
       subtitle = paste0("Decision threshold: ",
                         round(threshold, 3)),
       x = "Anomaly Score", y = "Density")

print(p6)
ggsave("fig07_anomaly_scores.png", p6,
       width = 9, height = 5, dpi = 300)
conf_mat <- confusionMatrix(pred_factor, label_factor,
                            positive = "Fraud")
print(conf_mat)
precision_val <- conf_mat$byClass["Precision"]
recall_val    <- conf_mat$byClass["Sensitivity"]
f1_val        <- conf_mat$byClass["F1"]
accuracy_val  <- conf_mat$overall["Accuracy"]

cat("\n--- KEY METRICS ---\n")
cat("Accuracy  :", round(accuracy_val  * 100, 2), "%\n")
cat("Precision :", round(precision_val * 100, 2), "%\n")
cat("Recall    :", round(recall_val    * 100, 2), "%\n")
cat("F1-Score  :", round(f1_val, 4), "\n")
roc_obj <- roc(labels_real, anomaly_scores, quiet = TRUE)
auc_val <- auc(roc_obj)
cat("AUC-ROC   :", round(auc_val, 4), "\n")
vp_n <- sum(pred_factor == "Fraud" & label_factor == "Fraud")
fp_n <- sum(pred_factor == "Fraud" & label_factor == "Normal")
fn_n <- sum(pred_factor == "Normal" & label_factor == "Fraud")
cat("\nTrue Positives  (detected frauds) :", vp_n, "\n")
cat("False Positives (false alerts)    :", fp_n, "\n")
cat("False Negatives (missed frauds)   :", fn_n, "\n")
cat("Detection rate                    :",
    round(vp_n / sum(labels_real) * 100, 1), "%\n")
png("fig08_roc_curve.png",
    width = 800, height = 700, res = 120)
plot(roc_obj,
     col  = "#e74c3c", lwd = 2,
     main = paste("ROC Curve — Isolation Forest\nAUC =",
                  round(auc_val, 4)),
     xlab = "False Positive Rate (1 - Specificity)",
     ylab = "True Positive Rate (Sensitivity)")
abline(a = 0, b = 1, lty = 2, col = "gray60")
legend("bottomright",
       legend = paste0("AUC = ", round(auc_val, 4)),
       col = "#e74c3c", lwd = 2, bty = "n")
dev.off()
cm_df <- as.data.frame(conf_mat$table)

p7 <- ggplot(cm_df,
             aes(x = Reference, y = Prediction,
                 fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq),
            size = 7, fontface = "bold") +
  scale_fill_gradient(low = "#f8f9fa",
                      high = "#e74c3c") +
  theme_minimal(base_size = 13) +
  labs(title = "Confusion Matrix — Isolation Forest",
       x = "Actual Class",
       y = "Predicted Class",
       fill = "Count")

print(p7)
ggsave("fig09_confusion_matrix.png", p7,
       width = 6, height = 5, dpi = 300)
predictions <- as.numeric(as.character(pred_factor))
result_type <- dplyr::case_when(
  labels_real == 1 & pred_factor == 1 ~ "True Positive",
  labels_real == 0 & pred_factor == 1 ~ "False Positive",
  labels_real == 1 & pred_factor == 0 ~ "False Negative",
  TRUE                                ~ "True Negative"
)

score_result_df <- data.frame(
  Score  = anomaly_scores,
  Result = result_type
) %>% filter(Result != "True Negative")

p8 <- ggplot(score_result_df,
             aes(x = Score, fill = Result)) +
  geom_histogram(bins = 40, alpha = 0.8) +
  scale_fill_manual(
    values = c("True Positive"  = "#27ae60",
               "False Positive" = "#f39c12",
               "False Negative" = "#e74c3c")) +
  theme_minimal(base_size = 12) +
  labs(title    = "Anomaly Score by Classification Outcome",
       subtitle = "(True Negatives excluded for readability)",
       x = "Anomaly Score", y = "Count")

print(p8)
ggsave("fig10_scores_by_outcome.png", p8,
       width = 9, height = 5, dpi = 300)
thresholds <- seq(0.40, 0.70, by = 0.01)

predictions <- ifelse(anomaly_scores >= threshold, 1, 0)

results_thresh <- purrr::map_df(thresholds, function(s) {
  pred_s <- ifelse(anomaly_scores >= s, 1, 0)
  tp_s   <- sum(pred_s == 1 & labels_real == 1)
  fp_s   <- sum(pred_s == 1 & labels_real == 0)
  fn_s   <- sum(pred_s == 0 & labels_real == 1)
  prec_s <- ifelse(tp_s + fp_s > 0,
                   tp_s / (tp_s + fp_s), 0)
  rec_s  <- ifelse(tp_s + fn_s > 0,
                   tp_s / (tp_s + fn_s), 0)
  f1_s   <- ifelse(prec_s + rec_s > 0,
                   2 * prec_s * rec_s / (prec_s + rec_s), 0)
  data.frame(Threshold = s,
             Precision = prec_s,
             Recall    = rec_s,
             F1        = f1_s)
})
optimal_thresh <- results_thresh$Threshold[
  which.max(results_thresh$F1)]
cat("Optimal threshold (max F1):", optimal_thresh, "\n")
cat("Maximum F1-Score          :",
    round(max(results_thresh$F1), 4), "\n")
p9 <- results_thresh %>%
  pivot_longer(cols      = c(Precision, Recall, F1),
               names_to  = "Metric",
               values_to = "Value") %>%
  ggplot(aes(x = Threshold, y = Value, color = Metric)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = optimal_thresh,
             linetype = "dashed", color = "gray40") +
  scale_color_manual(
    values = c("Precision" = "#3498db",
               "Recall"    = "#e74c3c",
               "F1"        = "#27ae60")) +
  theme_minimal(base_size = 12) +
  labs(title    = "Precision, Recall and F1-Score by Threshold",
       subtitle = paste0("Optimal threshold: ", optimal_thresh),
       x = "Decision Threshold",
       y = "Metric Value")

print(p9)
ggsave("fig11_threshold_sensitivity.png", p9,
       width = 9, height = 5, dpi = 300)
set.seed(42)

# Sub-sample (t-SNE is expensive on 280k rows)
idx_normal  <- sample(which(labels_real == 0), 2000)
idx_fraud   <- which(labels_real == 1)      # all frauds
idx_viz     <- c(idx_normal, idx_fraud)

features_sub <- features[idx_viz, ]
labels_sub   <- data_clean$Class[idx_viz]

cat("Running t-SNE on", nrow(features_sub),
    "observations...\n")

tsne_res <- Rtsne(features_sub,
                  dims       = 2,
                  perplexity = 30,
                  max_iter   = 1000,
                  verbose    = FALSE)

tsne_df <- data.frame(
  x     = tsne_res$Y[, 1],
  y     = tsne_res$Y[, 2],
  Class = labels_sub
)

p10 <- ggplot(tsne_df,
              aes(x = x, y = y, color = Class)) +
  geom_point(data  = filter(tsne_df, Class == "Normal"),
             alpha = 0.25, size = 0.8) +
  geom_point(data  = filter(tsne_df, Class == "Fraud"),
             alpha = 0.9,  size = 2.5) +
  scale_color_manual(values = c("Normal" = "#95a5a6",
                                "Fraud"  = "#e74c3c")) +
  theme_minimal(base_size = 12) +
  labs(title    = "t-SNE Visualization of Transactions",
       subtitle = "Frauds (red) vs Normal transactions (grey)",
       x = "t-SNE Component 1",
       y = "t-SNE Component 2")

print(p10)
ggsave("fig12_tsne.png", p10,
       width = 9, height = 7, dpi = 300)
cat("\n--- Sensitivity to number of trees ---\n")
trees_list <- c(10, 25, 50, 75, 100, 150, 200)
auc_list   <- c()

for (n in trees_list) {
  set.seed(42)
  m_tmp <- isolation.forest(
    data = features, ntrees = n,
    sample_size = 256, ndim = 1, nthreads = 1)
  s_tmp   <- predict(m_tmp, features)
  auc_tmp <- auc(roc(labels_real, s_tmp, quiet = TRUE))
  auc_list <- c(auc_list, as.numeric(auc_tmp))
  cat("  n_estimators =", sprintf("%3d", n),
      "-> AUC =", round(auc_tmp, 4), "\n")
}

ntrees_df <- data.frame(
  N_Trees = trees_list,
  AUC     = auc_list
)

p11 <- ggplot(ntrees_df, aes(x = N_Trees, y = AUC)) +
  geom_line(color = "#e74c3c", linewidth = 1.2) +
  geom_point(color = "#e74c3c", size = 3) +
  geom_hline(yintercept = as.numeric(auc_val),
             linetype = "dashed", color = "gray50") +
  theme_minimal(base_size = 12) +
  labs(title    = "AUC-ROC Sensitivity to Number of Trees",
       subtitle = paste0("Final model: n=100, AUC=",
                         round(auc_val, 4)),
       x = "Number of Trees (ntrees)",
       y = "AUC-ROC")

print(p11)
ggsave("fig13_sensitivity_ntrees.png", p11,
       width = 8, height = 4, dpi = 300)
cat("\n")
cat("==============================================\n")
cat("          FINAL RESULTS — ISOLATION FOREST\n")
cat("==============================================\n")
cat(sprintf("  Dataset             : %d transactions\n",
            nrow(data)))
cat(sprintf("  Frauds              : %d (%.4f%%)\n",
            sum(labels_real),
            mean(labels_real) * 100))
cat(sprintf("  True Positives      : %d\n",   vp_n))
cat(sprintf("  False Positives     : %d\n",   fp_n))
cat(sprintf("  False Negatives     : %d\n",   fn_n))
cat(sprintf("  Detection rate      : %.1f%%\n",
            vp_n / sum(labels_real) * 100))
cat(sprintf("  Accuracy            : %.2f%%\n",
            accuracy_val * 100))
cat(sprintf("  Precision           : %.4f\n",  precision_val))
cat(sprintf("  Recall              : %.4f\n",  recall_val))
cat(sprintf("  F1-Score            : %.4f\n",  f1_val))
cat(sprintf("  AUC-ROC             : %.4f\n",  auc_val))
cat("==============================================\n")
cat("All figures saved (fig01 to fig13).\n")
cat("Script completed successfully.\n")