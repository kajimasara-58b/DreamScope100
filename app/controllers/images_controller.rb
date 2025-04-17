class ImagesController < ApplicationController
  before_action :authenticate_user! # ユーザーがログインしていることを確認

  def generate_image
    goals = fetch_goals
    image = create_image(goals)

    # 画像を一時ファイルに保存
    temp_file = Tempfile.new(['generated_image', '.png'])
    image.write(temp_file.path)

    # GoalSummaryImage に保存
    goal_summary_image = GoalSummaryImage.create(user: current_user)
    goal_summary_image.image.attach(
      io: File.open(temp_file.path),
      filename: 'goal_summary_image.png',
      content_type: 'image/png'
    )

    # 一時ファイルを削除
    temp_file.close
    temp_file.unlink

    # 画像の URL を取得
    image_url = url_for(goal_summary_image.image)

    # JSON 形式で画像の URL を返す
    render json: { image_url: image_url, message: '画像が生成されました！' }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Image generation failed: #{e.message}")
    render json: { error: '画像生成に失敗しました。' }, status: :unprocessable_entity
  end

  private

  def fetch_goals
    current_user.goals # 現在のユーザーの目標を取得
  end

  def create_image(goals)
    require 'mini_magick'

    # A4サイズのキャンバスを作成（595x842ピクセル、解像度72dpi）
    image = MiniMagick::Image.open('white') # 白い背景を作成
    image.resize '595x842' # A4サイズにリサイズ
    image.format 'png'

    # フォント設定
    image.combine_options do |c|
      c.font 'Arial' # 環境に合わせてフォントを指定
      c.fill 'black'
      c.pointsize 20
    end

    # 目標を2列に分けて描画
    goals.each_with_index do |goal, index|
      x = 50 + (index % 2) * 300
      y = 50 + (index / 2) * 30
      image.combine_options do |c|
        c.draw "text #{x},#{y} '#{goal.title}'"
      end
    end

    image
  end
end