class ImagesController < ApplicationController
  def generate_image
    goals = fetch_goals # 目標を取得するメソッドを呼び出す
    image = create_image(goals) # 画像を生成するメソッドを呼び出す
    send_data image.to_blob, filename: "output.jpg", type: "image/jpeg", disposition: "attachment" # 画像を返す
  end

  private

  def fetch_goals
    Goal.all # 目標を100件取得
  end

  def create_image(goals)
    require 'mini_magick'

    image = MiniMagick::Image.create("png") do |f|
      f.write("A4サイズのキャンバスに目標を描く処理")
    end

    # ここで目標を2列に分けて描画する処理を追加
    goals.each_with_index do |goal, index|
      x = (index % 2) * 300 # x座標の計算
      y = (index / 2) * 50   # y座標の計算
      image.combine_options do |c|
        c.draw "text #{x},#{y} '#{goal.title}'"
      end
    end

    image
  end
end