class AdminSettingPolicy

attr_reader :user, :admin_setting

def initialize(user, admin_setting)
@user = user
    @admin_setting = admin_setting
end

def settings?
user.has_role? :admin
end
end