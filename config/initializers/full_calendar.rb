# FULLCALENDAR_FILE_PATH = Rails.root.join('config', 'fullcalendar.yml')
# config = File.exists?(FULLCALENDAR_FILE_PATH) ? YAML.load_file(FULLCALENDAR_FILE_PATH) || {} : {}

APP_CONFIG = {
  'editable'    => true,
  'header'      => {
    left: 'prev,next today',
    center: 'title',
    right: 'month,agendaWeek,agendaDay'
  },
  'allDayText' => 'All Day',
  'axisFormat'  => 'h(:mm) TT',
  'defaultView' => 'agendaWeek',
  'height'      => 500,
  'slotMinutes' => 15,
  'dragOpacity' => 0.5,
  'selectable'  => true,
  'timeFormat'  => "h:mm t{ - h:mm t}"
}

RECURRING_EVENTS_UPTO = (Date.today.beginning_of_year + 1.years).to_time
# FullcalendarEngine::Configuration.merge!(config)
# FullcalendarEngine::Configuration['events'] = "aaa"