module StashMetadata
  module Tasks
    module Export

      def self.start(args)
        FileUtils.mkdir_p(STASH_SCENES_DIRECTORY)     unless File.directory?(STASH_SCENES_DIRECTORY)
        FileUtils.mkdir_p(STASH_PERFORMERS_DIRECTORY) unless File.directory?(STASH_PERFORMERS_DIRECTORY)

        scene_mappings = []
        Scene.all.each do |scene|
          scene_mappings.push({path: scene.path, checksum: scene.checksum})

          json = {}
          json[:title] = scene.title if scene.title
          json[:studio] = scene.studio.name if scene.studio && scene.studio.name
          json[:url] = scene.url if scene.url
          json[:details] = scene.details if scene.details
          json[:performers] = get_names(scene.performers) unless get_names(scene.performers).empty?
          json[:tags] = get_names(scene.tags) unless get_names(scene.tags).empty?

          next if json.empty?

          sceneJSON = StashMetadata::JSON.scene(scene.checksum)
          next if sceneJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{sceneJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_scene(checksum: scene.checksum, json: json)
          end
        end

        performer_mappings = []
        Performer.all.each do |performer|
          performer_mappings.push({name: performer.name, checksum: performer.checksum})

          json = {}
          json[:name] = performer.name if performer.name
          json[:url] = performer.url if performer.url

          next if json.empty?

          performerJSON = StashMetadata::JSON.performer(performer.checksum)
          next if performerJSON == json.as_json

          if args[:dry_run]
            StashMetadata.logger.info("WRITE\nJSON: #{json}\nFILE #{performerJSON}\n\n\n--------") # Dry run
          else
            StashMetadata::JSON.save_performer(checksum: performer.checksum, json: json)
          end
        end

        mappings = {performers: performer_mappings, scenes: scene_mappings}
        StashMetadata::JSON.save_mappings(json: mappings)
      end

      private

      def self.get_names(objects)
        return nil unless objects

        objects.reduce([]) { |names, object|
          unless object.name.nil?
            names << object.name
          end

          names
        }
      end

    end
  end
end