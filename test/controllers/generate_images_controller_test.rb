# app/controllers/generate_images_controller.rb
class GenerateImagesController < ApplicationController
  protect_from_forgery with: :null_session # fetch API対応（セキュリティ注意）

  def create
    # 仮で、白背景の空画像を作る（あとでカスタマイズする）
    require "mini_magick"

    image = MiniMagick::Image.create("png") do |f|
      f.write ""
    end
    image.combine_options do |c|
      c.size "600x400"
      c.gravity "center"
      c.xc "white"
    end

    filename = "generated_image_#{SecureRandom.hex(10)}.png"
    filepath = Rails.root.join("tmp", filename)
    image.write(filepath)

    # 一時ファイルをBase64に変換してフロントに返す
    base64_image = Base64.strict_encode64(File.read(filepath))

    render json: { image_data: "data:image/png;base64,#{base64_image}" }
  end
end
