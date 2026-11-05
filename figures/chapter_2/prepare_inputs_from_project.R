library(dplyr)
library(tidyr)

# Notebook cell 8
load (file = "02_scripts/00_data_preparation/processed_data/data.Rdata")

# Notebook cell 33
df_efficacy = data %>% 

    mutate (id = row_number(), .before = e.cum) %>%

    # For eid 452 and 661: remove the last observation of one trial
    # to align final time points across application techniques:
    filter (! (id %in% c (3440, 5551))) %>% 

    mutate (app.mthd = paste (app.mthd, incorp)) %>%

    # Retain experiments with at least one broadcast application
    filter (eid %in% eid [app.mthd == "bc none"]) %>% 

    # Keep experiments that include at least one non-broadcast application method
    filter (eid %in% eid [app.mthd != "bc none"]) %>%

    filter (ct == max (ct), .by = pmid) %>% 
    select (- j.NH3, - exper, - country, - incorp, - meas.tech, - dt, - field, - id)



# Notebook cell 37
# eid ok
eid_ok = c (243, 244, 245, 246, 247, 248, 384, 452, 455, 456, 561, 562, 567, 569, 594, 595, 596, 599, 
            605, 606, 610, 611, 612, 615, 616, 620, 645, 650, 603, 618, 622, 623, 625, 626, 627, 630, 
            636, 639, 646, 649, 653, 661)

# eid with multiple "bc none" trials => compute the average emissions for "bc none"
eid_with_several_bc_none = c (260, 284, 287, 613, 637, 638, 655, 660, 662, 663, 664, 665, 666, 667)

# eid 628: some trials with cattle and some trials with pig => group by manure source
# and for cattle: two trials with bc method => compute the average for these two trials

# eid 597: 4 trials with a duration close to 45h and 4 trials with a duration close to 70h
# => group by trial duration

# Note: significant variability in the application rate for the following eids:
# 603, 618, 622, 623, 625, 626, 627, 630, 636, 639, 646, 649, 653, 661, 660, 662, 663, 664, 665, 666, 667

# Notebook cell 38
# eid ok
df_efficacy_1 = df_efficacy %>% 
    filter (eid %in% eid_ok) 

# Notebook cell 39
# for eid with multiple "bc none" trials, we merge these trials into one by averaging the emissions.
# this is necessary in order to compute the efficacy.

df_efficacy_fix1 = df_efficacy %>%

    filter (eid %in% eid_with_several_bc_none) %>% 
    filter (app.mthd == "bc none") %>%

    summarise (e.cum = mean (e.cum),
               e.rel = mean (e.rel),
               pmid = pmid [1],
               inst = inst [1],
               ct = mean (ct),
               air.temp = mean (air.temp),
               wind.2m = mean (wind.2m),
               rain.rate = mean (rain.rate),
               tan.app = mean (tan.app),
               app.rate = mean (app.rate),
               man.dm = mean (man.dm),
               man.ph = mean (man.ph),
               man.source = man.source[1],
               t.incorp = t.incorp[1],
               app.mthd = app.mthd[1],
               .by = eid) %>%

    relocate (eid, .after = pmid)


df_efficacy_fix2 = df_efficacy %>%
    filter (eid %in% eid_with_several_bc_none) %>% 
    filter (app.mthd != "bc none") 

df_efficacy_2 = rbind (
    df_efficacy_fix1,
    df_efficacy_fix2
)

# Notebook cell 42
df_efficacy_fix_628 = df_efficacy %>%
    filter (eid == 628)

df_efficacy_fix3_1 = df_efficacy_fix_628 %>%
    filter (pmid %in% c (3206, 3207)) %>%
    mutate (eid = 1)

df_efficacy_fix3_2 = df_efficacy_fix_628 %>%
    filter (pmid %in% c (3208, 3210)) %>%
    mutate (eid = 2)

df_efficacy_fix3_3 = df_efficacy_fix_628 %>%
    filter (pmid %in% c (3209, 3211)) %>%
    mutate (eid = 3)


# Notebook cell 43
df_efficacy_3 = rbind (
    df_efficacy_fix3_1,
    df_efficacy_fix3_2,
    df_efficacy_fix3_3
)

df_efficacy_3

# Notebook cell 44
df_efficacy_fix_597 = df_efficacy %>%
    filter (eid == 597)



# Notebook cell 45
df_efficacy_4 = df_efficacy_fix_597 %>%
    mutate (eid = c (4, 4, 5, 5, 5, 4, 4, 5)) %>% arrange (eid)

# Notebook cell 46
df_efficacy_clean = rbind (df_efficacy_1, df_efficacy_2, df_efficacy_3, df_efficacy_4)

# Notebook cell 47
df_plot = df_efficacy_clean %>%
    mutate (efficacy = ((e.rel / e.rel[app.mthd == "bc none"]) - 1) * 100, .by = c (eid))

# Notebook cell 52
load (file = "02_scripts/01_ALFAM2/results/df_res_ALFAM2.Rdata")

# Notebook cell 55
files <- dir("02_scripts/03_static_nn/results/02_model_comparison/df_res/", pattern = "df_res", full.names = TRUE)

# Notebook cell 56
df_res_static_nn <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 60
files <- dir("02_scripts/03_static_nn/results/03_static_nn_12_with_normalisation/df_res/", pattern = "df_res", full.names = TRUE)

# Notebook cell 61
df_res_static_nn_with_normalisation <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 66
files <- dir("02_scripts/04_rnn/results/04_hidden_size_choice/df_res", pattern = "df_res", full.names = TRUE)

# Notebook cell 67
df_selection_of_h <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 72
files <- dir("02_scripts/04_rnn/results/05_1_model_comparison/df_res", pattern = "df_res", full.names = TRUE)

df_res_rnn <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 73
rnn_models = read.csv (file = "02_scripts/04_rnn/results/rnn_models.csv")

df_res_rnn = df_res_rnn %>%
    left_join (rnn_models, by = "model")

# Notebook cell 76
df_res_rnn_ecum = df_res_rnn %>%
    filter (model %in% c (1 : 8))

df_res_rnn_delta_ecum = df_res_rnn %>%
    filter (model %in% c (9 : 16))

df_res_rnn_ecum_delta_ecum = df_res_rnn %>%
    filter (model %in% c (17 : 24))

# Notebook cell 77
df_res_rnn_delta_ecum = df_res_rnn_delta_ecum %>%
    mutate (prediction_ecum = cumsum (prediction_delta_ecum), .by = c (sample, model, pmid))

# Notebook cell 78
df_res_rnn_ecum_delta_ecum_1 = df_res_rnn_ecum_delta_ecum %>%
    mutate (model = paste (model, "ecum"))

# Notebook cell 79
df_res_rnn_ecum_delta_ecum_2 = df_res_rnn_ecum_delta_ecum %>%
    mutate (prediction_ecum = cumsum (prediction_delta_ecum), .by = c (sample, model, pmid)) %>%
    mutate (model = paste (model, "delta_ecum"))

# Notebook cell 80
df_res_rnn_all = rbind (
    df_res_rnn_ecum %>% mutate (response2 = "ecum"),
    df_res_rnn_delta_ecum %>% mutate (response2 = "delta_ecum"),
    df_res_rnn_ecum_delta_ecum_1 %>% mutate (response2 = "ecum2"),
    df_res_rnn_ecum_delta_ecum_2 %>% mutate (response2 = "delta_ecum2")
)

# Notebook cell 81
level_models = c (
    "1", "2", "3", "4", "5", "6", "7", "8",
    "9", "10", "11", "12", "13", "14", "15", "16",
    "17 ecum", "18 ecum", "19 ecum", "20 ecum", "21 ecum", "22 ecum", "23 ecum", "24 ecum",
    "17 delta_ecum", "18 delta_ecum", "19 delta_ecum", "20 delta_ecum", "21 delta_ecum", "22 delta_ecum", "23 delta_ecum", "24 delta_ecum"
)

level_models = paste ("rnn", level_models)

# Notebook cell 88
files <- dir("02_scripts/04_rnn/results/05_2_model_comparison_with_interpolation/df_res", pattern = "df_res", full.names = TRUE)

df_res_rnn_with_interpolation <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 90
# Adding e.cum = 0 at t = 0, for all the trials

df_zero = NULL

samples = df_res_rnn_with_interpolation$sample %>% unique

for (i in samples){
    df_sample = df_res_rnn_with_interpolation %>% filter (sample == i)
    pmids = df_sample %>% pull (pmid) %>% unique

    for (k in pmids){
        df_tmp = df_sample %>% filter (pmid == k)
        df_tmp = rbind (
            df_tmp[1, ] %>% mutate (prediction_ecum = 0, ct = 0),
            df_tmp
        )

        df_zero = rbind (df_tmp, df_zero)
    }
}

# Notebook cell 91
# Interpolation at measured times

df_res_rnn_interpolated = NULL

for (i in samples){
    df_sample = df_zero %>% filter (sample == i)
    pmids = df_sample %>% pull (pmid) %>% unique

    for (k in pmids){
        df_tmp = df_sample %>% filter (pmid == k)

        df_res_rnn_interpolated_tmp = data %>% filter (pmid == k)

        real_times = df_res_rnn_interpolated_tmp %>% pull (ct) 
        interpolation = approx (df_tmp$ct, df_tmp$prediction_ecum, xout = real_times)

        df_res_rnn_interpolated_tmp = df_res_rnn_interpolated_tmp %>%
            mutate (prediction_ecum = interpolation$y) %>%
            mutate (sample = i)
        
        df_res_rnn_interpolated = rbind (df_res_rnn_interpolated, df_res_rnn_interpolated_tmp)
    }
}

# Notebook cell 94
files <- dir("02_scripts/04_rnn/results/05_3_model_comparison_with_data_augmentation/df_res", pattern = "df_res", full.names = TRUE)

# Notebook cell 95
df_res_rnn_with_data_augmentation <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 99
files <- dir("02_scripts/04_rnn/results/05_4_model_comparison_with_data_augmentation_with_normalisation/df_res", pattern = "df_res", full.names = TRUE)

# Notebook cell 100
df_res_rnn_with_normalisation <- do.call(rbind, lapply(files, function(x) read.csv(x)))

# Notebook cell 106
load (file = "02_scripts/04_rnn/results/07_time_seq_effect/predictions_without_data_a_on_observed_times.Rdata")

predictions_without_data_a_on_observed_times = predictions_without_data_a_on_observed_times %>%
    mutate (seq = recode (seq, "dt = 2.0" = "dt = 2"))

# Notebook cell 109
load (file = "02_scripts/04_rnn/results/07_time_seq_effect/predictions_with_data_a_on_observed_times.Rdata")

predictions_with_data_a_on_observed_times = predictions_with_data_a_on_observed_times %>%
    mutate (seq = recode (seq, "dt = 2.0" = "dt = 2", "dt = 4.0" = "dt = 4", "dt = 6.0" = "dt = 6", "dt = 8.0" = "dt = 8", "dt = 10.0" = "dt = 10"))

# Notebook cell 118
load (file = "02_scripts/02_random_forest/results/statique/df_res_random_forest_statique.Rdata")
df_res = df_res_random_forest_statique

# Notebook cell 124
files <- dir("02_scripts/02_random_forest/results/dynamique_without_interpolation/", pattern = "df_res_sample_", full.names = TRUE)

df_res_random_forest_dynamique_without_interpolation <- do.call(rbind, lapply(files, function(x) get(load(x))))

# Notebook cell 128
files <- dir("02_scripts/02_random_forest/results/dynamique", pattern = "df_res_sample_", full.names = TRUE)

df_res_random_forest_dynamique <- do.call(rbind, lapply(files, function(x) get(load(x))))

# Notebook cell 132
files <- dir("02_scripts/02_random_forest/results/dynamique_data_a/", pattern = "df_res_sample_", full.names = TRUE)

df_res_random_forest_dynamique_data_a <- do.call(rbind, lapply(files, function(x) get(load(x))))

# Notebook cell 134
df_res_all_static = rbind (

    # results for ALFAM2
    df_res_ALFAM2 %>%
        filter (ct == max (ct), .by = pmid) %>%
        select (sample, pmid, e.cum, ct, prediction_ecum) %>%
        mutate (running_time = NA) %>%
        mutate (model = "", .after = sample) %>%
        mutate (model_type = "ALFAM2", .before = sample),

    # results for 'static rf'
    df_res_random_forest_statique %>%
        select (sample, pmid, e.cum, ct, prediction_ecum = e.cum_hat) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (running_time = NA) %>%
        mutate (model = "", .after = sample) %>%
        mutate (model_type = "static rf", .before = sample),

    # results for 'static nn 1', 'static nn 2', ..., 'static nn 12'
    df_res_static_nn %>% 
        mutate (model_type = "static nn", .before = sample)%>%
        mutate (sample = sample + 1),

    # results for 'dynamic rf - 2', 'dynamic rf - 4', ..., 'dynamic rf - 10'
    df_res_random_forest_dynamique %>%
        filter (ct == max (ct), .by = pmid) %>%
        mutate (dt = as.character (dt)) %>%
        mutate (dt = paste ("-", dt)) %>% 
        select (sample, model = dt, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'dyamic rf'
    df_res_random_forest_dynamique_without_interpolation %>%
        filter (ct == max (ct), .by = pmid) %>%
        mutate (model = "") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'dynamic rf - data a.'
    df_res_random_forest_dynamique_data_a %>%
        filter (ct == max (ct), .by = pmid) %>%
        mutate (model = "- data a.") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'rnn 9'
    df_res_rnn_all %>%
        filter (ct == max (ct), .by = pmid) %>%
        filter (model == "9") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1),

    # results for 'rnn 9 - 2'
    df_res_rnn_interpolated %>%
        filter (ct == max (ct), .by = pmid) %>%
        mutate (model = "9 - 2", running_time = NA) %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1),

    # results for 'rnn 9 - data a.'
    df_res_rnn_with_data_augmentation %>%
        filter (ct == max (ct), .by = pmid) %>%
        mutate (model = "9 - data a.", running_time = NA) %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1)

) %>%
    mutate (Model = paste (model_type, model)) %>%
    mutate (Model = factor (Model, 
                            levels = c ("ALFAM2 ", 
                                        "rnn 9", "rnn 9 - 2", "rnn 9 - data a.", 
                                        "dynamic rf - 2", "dynamic rf - 4", "dynamic rf - 6", "dynamic rf - 8", "dynamic rf - 10", 
                                        "dynamic rf ", "dynamic rf - data a.", 
                                        "static nn 1", "static nn 2", "static nn 3", "static nn 4", "static nn 5", "static nn 6", 
                                        "static nn 7", "static nn 8", "static nn 9", "static nn 10", "static nn 11", "static nn 12", 
                                        "static rf ")))

# Notebook cell 148
df_res_all_dynamic = rbind (

    # results for the ALFAM2 model
    df_res_ALFAM2 %>%
        select (sample, pmid, e.cum, ct, prediction_ecum) %>%
        mutate (running_time = NA) %>%
        mutate (model = "", .after = sample) %>%
        mutate (model_type = "ALFAM2", .before = sample),

    # results for 'dynamic rf - 2', 'dynamic rf - 4', ..., 'dynamic rf - 10'
    df_res_random_forest_dynamique %>%
        mutate (dt = as.character (dt)) %>%
        mutate (dt = paste ("-", dt)) %>%
        select (sample, model = dt, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'dynamic rf'
    df_res_random_forest_dynamique_without_interpolation %>%
        mutate (model = "") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'dynamic rf - data a.'
    df_res_random_forest_dynamique_data_a %>%
        mutate (model = "- data a.") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum = e.cum_hat, running_time) %>%
        mutate (sample = as.integer (gsub ("sample_", "", sample))) %>%
        mutate (model_type = "dynamic rf", .before = sample),

    # results for 'rnn 9'
    df_res_rnn_all %>%
        filter (model == "9") %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1),

    # results for 'rnn 9 - 2'
    df_res_rnn_interpolated %>%
        mutate (model = "9 - 2", running_time = NA) %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1),

    # results for 'rnn 9 - data a.'
    df_res_rnn_with_data_augmentation %>%
        mutate (model = "9 - data a.", running_time = NA) %>%
        select (sample, model, pmid, e.cum, ct, prediction_ecum, running_time) %>%
        mutate (model_type = "rnn", .before = sample) %>%
        mutate (sample = sample + 1)
    
) %>%
    mutate (Model = paste (model_type, model)) %>%
    mutate (Model = factor (Model, 
                            levels = c ("ALFAM2 ", 
                                        "rnn 9", "rnn 9 - 2", "rnn 9 - data a.", 
                                        "dynamic rf - 2", "dynamic rf - 4", "dynamic rf - 6", "dynamic rf - 8", "dynamic rf - 10", 
                                        "dynamic rf ", "dynamic rf - data a.")))

# Notebook cell 158
load (file = "02_scripts/01_ALFAM2/results/predictions_on_scenarios_ALFAM2.Rdata")

df_efficacy_ALFAM2 = predictions_on_scenarios_ALFAM2

# Notebook cell 161
load (file = "02_scripts/02_random_forest/results/predictions_on_scenarios_static_random_forest.Rdata")

# Notebook cell 162
df_efficacy_static_rf = predictions_on_scenarios_static_random_forest %>%
    mutate (model = "static rf")



# Notebook cell 165
scenarios_predictions_static_nn = read.csv (file = "02_scripts/03_static_nn/results/04_predictions_on_scenarios/predictions_on_scenarios_static_nn.csv")

# Notebook cell 166
df_efficacy_static_nn = scenarios_predictions_static_nn %>% 
    mutate (efficacy = ((prediction_ecum / prediction_ecum[strategy == "Broadcast"]) - 1) * 100, 
            .by = c (scenario)) %>%
    mutate (model = "static nn 12") 

# Notebook cell 169
load (file = "02_scripts/02_random_forest/results/predictions_on_scenarios_dynamic_random_forest.Rdata")

# Notebook cell 171
load (file = "02_scripts/00_data_preparation/processed_data/scenarios_dynamic_rf.Rdata")

df_groups = scenarios_dynamic_rf %>% 
    select (scenario, pmid, strategy, group_temp, group_wind, group_rain) %>%
    distinct

# Notebook cell 172
df_efficacy_dynamic_rf = predictions_on_scenarios_dynamic_random_forest %>%
    left_join (df_groups, by = "pmid") %>%
    filter (ct == max (ct), .by = pmid) %>%
    mutate (efficacy = ((e.cum_hat / e.cum_hat[strategy == "Broadcast"]) - 1) * 100, 
            .by = c (scenario)) %>%
    mutate (model = "dynamic rf - 2")

# Notebook cell 176
predictions_on_scenarios_rnn_data_augmentation = read.csv (file = "02_scripts/04_rnn/results/06_predictions_on_scenarios/predictions_on_scenarios_rnn_data_augmentation.csv")

# Notebook cell 178
df_efficacy_rnn_data_augmentation = predictions_on_scenarios_rnn_data_augmentation %>%
    filter (ct == max (ct), .by = pmid) %>%
    mutate (efficacy = ((prediction_ecum / prediction_ecum[strategy == "Broadcast"]) - 1) * 100, 
            .by = c (scenario, seq)) %>%
    mutate (model = paste ("dt =", seq)) %>%
    mutate (model = factor (model, levels = c ("dt = 2", "dt = 4", "dt = 6", "dt = 8", "dt = 10"))) %>%
    {.}

dir.create('thesis_figures/data', recursive=TRUE, showWarnings=FALSE)
save(data, df_plot, df_selection_of_h, df_res_rnn_all, level_models, df_res_static_nn, df_res_static_nn_with_normalisation, df_res_rnn_with_data_augmentation, df_res_rnn_with_normalisation, predictions_without_data_a_on_observed_times, predictions_with_data_a_on_observed_times, df_res_all_static, df_res_all_dynamic, df_efficacy_ALFAM2, df_efficacy_static_rf, df_efficacy_dynamic_rf, df_efficacy_static_nn, df_efficacy_rnn_data_augmentation, file='thesis_figures/data/plot_inputs.RData', compress='xz')
