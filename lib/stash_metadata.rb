module StashMetadata
  STASH_DIRECTORY            = File.join(Dir.home, '.stash')
  STASH_PERFORMERS_DIRECTORY = File.join(STASH_DIRECTORY, 'performers')
  STASH_SCENES_DIRECTORY     = File.join(STASH_DIRECTORY, 'scenes')
  STASH_MAPPINGS_FILE        = File.join(STASH_DIRECTORY, 'mappings.json')

  def self.import
    mappings = StashMetadata::JSON.mappings
    return unless mappings

    mappings['performers'].each { |performerJSON|
      checksum = performerJSON['checksum']
      name = performerJSON['name']
      json = StashMetadata::JSON.performer checksum
      next unless checksum && name && json

      performer = Performer.new
      performer.checksum = checksum
      performer.name = name
      performer.url = json['url']

      performer.save
    }

    mappings['scenes'].each { |sceneJSON|
      checksum = sceneJSON['checksum']
      path = sceneJSON['path']
      unless checksum && path
        logger.warning "Scene mapping without checksum and path! #{sceneJSON}"
        next
      end

      scene = Scene.new
      scene.checksum = checksum
      scene.path     = path

      json = StashMetadata::JSON.scene checksum
      if json
        scene.title    = json['title']
        scene.details  = json['details']
        scene.url      = json['url']

        # TODO studio

        performer_names = json['performers']
        if performer_names
          performer_names.each { |performer_name|
            performer = Performer.find_by(name: performer_name)
            if performer
              scene.performers.push(performer)
            else
              logger.warning "Performer does not exist! #{performer_name}"
            end
          }
        end

        # TODO tags
      end

      scene.save
    }

  end
end