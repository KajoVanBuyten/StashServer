json.(studio, :id, :checksum, :name, :url)
json.image_path studio_image_path(studio.id)
json.scene_count studio.scenes.count
