require 'fog'

require 'rain/version'
require 'rain/providers/vcloud/base'

require 'rain/util/logging'
require 'rain/util/dynamic_create'
require 'rain/util/jsonpath'
require 'rain/util/hashutil'
require 'rain/util/deep_merge/core'
require 'rain/util/deep_merge/deep_merge_hash'
require 'rain/util/safe_puts'
require 'rain/util/format/core'



require 'rain/config'
require 'rain/errors'

# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file

require 'rainbow'
require 'rain/main'


require 'rain/command/cmd_config'
require 'rain/command/cmd_env'
require 'rain/command/cmd_firewall'
require 'rain/command/cmd_image'
require 'rain/command/cmd_nat'
require 'rain/command/cmd_network'
require 'rain/command/cmd_server'
require 'rain/command/cmd_zone'


#require 'rain/modellers/yaml/base'

require 'vcloud'
require 'vcloud/vapp'


module Rain
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

end

I18n.enforce_available_locales = false
I18n.load_path << File.expand_path("etc/i18n/en.yml", Rain.source_root)
