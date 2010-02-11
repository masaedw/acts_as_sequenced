# Include hook code here
ActiveRecord::Base.send :include, Mofumofu::Acts::Sequenced
