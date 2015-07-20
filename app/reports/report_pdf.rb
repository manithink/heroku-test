  class ReportPdf < Prawn::Document
  include ActionView::Helpers::TextHelper

  def initialize
    super()
    logo
    line
    summary
    table_box_summary
    table_box_service
    table_view
  end

  def logo
    bounding_box([0,cursor],width: 100) do 
      image "#{Rails.root}/app/assets/images/favicon.png", width: 141, height: 60
    end
    move_up 60
    bounding_box([370,cursor],width: 300) do 
      text "Farcare INC", style: :bold
      text "3719 old Alabama"
      text "Johns Creek, Georgia 30022, USA"
    end

  end

  def line
    move_down 20
    move_to 1000,0
      stroke do
      horizontal_line 200, 500, :at => 150


    end
    fill_color "2c3e50"
    fill_rectangle [0,cursor], 540, 30
    fill_color "ffffff"
    text_box "Care Client Report", :at => [10,cursor-8]
    text_box "From 3/1/2010 to 31/1/2010", :at => [370,cursor-8]
  end

  def summary
    move_down 40
    fill_color "626262"
    text "Summary", style: :bold, size: 12

  end

  def table_box_summary
    move_down 10
    stroke_color "879cb1"
    stroke_rectangle [0, cursor], 540, 150

    move_down 10
    fill_color "2c3e50"
    text_box "Care Cleint Name", size: 12, style: :bold, :at => [10,cursor]

    move_down 10
    fill_color "626262"
    text_box "Firt Name:    Vishnu", :at => [10,cursor-8]
    text_box "Last Name:    VN", :at => [150,cursor-8]

  end

  def table_box_service
    move_down 10
    stroke_color "879cb1"
    stroke_rectangle [0, cursor-140], 540, 300

    fill_color "626262"
    move_down 10
    fill_color "626262"
    text_box "Check In: 12/2/2010 02:40 PM", :at => [10,cursor-150]
    text_box "Check Out: 12/2/2010 02:40 PM", :at => [350,cursor-150]

  end

  def table_view
    stroke do

      line_to 540, 0
# line_to 0, 100

      # curve_to [150, 250], :bounds => [[20, 200], [120, 200]]
    end



  end
end