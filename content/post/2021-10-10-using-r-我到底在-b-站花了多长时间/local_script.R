library("httr")
# Generate a Cookies, at Oct 10th, 2021
cookies <-
  httr::set_cookies(
    DedeUserID	 = "10999644",
    DedeUserID__ckMd5 = "abef155ad3368331",
    SESSDATA = curl::curl_unescape("8100979a%2C1647763657%2Cf01f4%2A91"),
    bili_jct = curl::curl_unescape("0d7f515de7c3edf5034f79665fdb5b1d")
  )

library("jsonlite")
library("pillar")
library("purrr")
library("dplyr")
library("tibble")

pn_ls <-
  c(1:4)

history_resp_ls <-
  map(pn_ls,
      function(pn) {
        history_resp <-
          httr::GET(url =
                      "http://api.bilibili.com/x/v2/history",
                    config = cookies,
                    query = list(pn = pn))
        
        history_content <-
          httr::content(history_resp, type = "text")
        
        # The response of GET is a json
        history_from_json <-
          jsonlite::fromJSON(history_content)
        
        # The history records are in `data`
        history_from_json$data
      })

history_tb <-
  reduce(history_resp_ls, bind_rows) %>%
  as_tibble()

glimpse(history_tb)
head(history_tb)

history_tb %>% 
  # select(duration,
  #        progress) %>% 
  mutate(
    duration_time = 
      ifelse(
        progress<0,
        duration,
        progress
      )
  ) %>% 
  summarize(
    sum(duration_time)
  )

# when_view_viz
library("lubridate")
library("ggplot2")
library("cowplot")
library("ggtech")
library("forcats")

histroy_tidy_tb <-
  history_tb %>%
  mutate(
    tname = fct_reorder(tname, tid),
    play_time = 
      if_else(progress<0, duration, progress),
    pubdate = 
      as.POSIXct(pubdate, origin = "1970-01-01"),
    view_at =
      as.POSIXct(view_at, origin = "1970-01-01"),
    date = date(view_at),
    time = round(local_time(view_at, units = "hours")),
    dow = wday(view_at, week_start = 1)
  )

view_date_p <-
  histroy_tidy_tb %>%
  group_by(date) %>%
  summarise(duration_sum = sum(play_time, na.rm = TRUE)/3600) %>%
  ggplot(aes(x = date, y = duration_sum)) +
  geom_line() +
  scale_x_date(
    "",
    date_breaks = "7 day") +
  ylab("Total Play Time (Hour)")

view_time_p <-
  histroy_tidy_tb %>%
  group_by(time) %>%
  summarise(duration_mean = mean(play_time, na.rm = TRUE)/3600) %>%
  ggplot(aes(x = time, y = duration_mean)) +
  geom_col() +
  scale_x_continuous(
    "Time of Day",
    limits = c(0, 24)) +
  ylab("Mean Play Time (Hour/day)")

view_dow_p <-
  histroy_tidy_tb %>%
  group_by(dow) %>%
  summarise(duration_mean = mean(play_time, na.rm = TRUE)/3600) %>%
  ggplot(aes(x = dow, y = duration_mean)) +
  geom_col() +
  scale_x_continuous("Day of Week") +
  ylab("Mean Play Time (Hour/day)")

view_bottom_grid_p <-
  plot_grid(view_time_p,
            view_dow_p,
            labels = c("B", "C"))

view_grid_p <-
  plot_grid(view_date_p,
            view_bottom_grid_p,
            labels = c("A", ""),
            nrow = 2)

view_grid_p

# category_viz

library(forcats)
library(showtext)

showtext_auto()

histroy_tidy_tb %>% 
  select(
    tname,
    play_time
  ) %>% 
  group_by(tname) %>% 
  summarise(duration_sum = sum(play_time, na.rm = TRUE)/3600) %>% 
  mutate(tname = fct_reorder(
    tname, duration_sum
  )) %>% 
  ggplot(aes(x = tname,
             y = duration_sum)) +
  geom_col() +
  coord_flip() +
  labs(x = "播放时长 （小时）",
       y = "子分类") +
  theme(text = element_text(family = "source-han-sans-cn"))

# category_time_viz

histroy_tidy_tb %>% 
  group_by(time, tname) %>%
  summarise(duration_mean_by_type = mean(play_time, na.rm = TRUE)/3600)  %>%
  # group_by(date, tname) %>%
  # mutate(duration_sum_by_type = sum(play_time, na.rm = TRUE)/3600) %>%
  select(
    tname, time, duration_mean_by_type
  ) %>% 
  ggplot(aes(x = time,
             y = duration_mean_by_type,
             fill = tname
             # label = tname
             )) +
  geom_col()
  # geom_text(position = position_stack())

history_type_aggregate_tb <-
  histroy_tidy_tb %>%
  select(tname,
         play_time) %>%
  group_by(tname) %>%
  summarise(duration_sum = sum(play_time, na.rm = TRUE) / 3600) %>%
  mutate(percentage = duration_sum / sum(duration_sum),
         tname = as.character(tname)) %>%
  mutate(type = if_else(percentage >= .01, tname, 'other')) %>%
  group_by(type) %>%
  summarise(duration_sum = sum(duration_sum)) %>% 
  arrange(desc(duration_sum))

knitr::kable(history_type_aggregate_tb)

library("colorspace")

showtext_auto()

histroy_tidy_tb %>% 
  mutate(
    tname = as.character(tname),
    type = if_else(tname %in% history_type_aggregate_tb$type, 
                   tname,
                   "other"
    )) %>% 
  group_by(time, type) %>%
  summarise(duration_mean_by_type = mean(play_time, na.rm = TRUE)/3600)  %>%
  select(
    type, time, duration_mean_by_type
  ) %>% 
  ggplot(aes(x = time,
             y = duration_mean_by_type,
             fill = type,
             label = type
  )) +
  geom_col() +
  labs(x = "Time of Day",
       y = "Play Duration\n(Hour)") +
  theme_classic() +
  scale_fill_discrete_sequential("Batlow")
