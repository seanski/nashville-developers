module ApplicationHelper
  def header(&block)
    content_tag(:header, class: 'navbar navbar-inverse', role: 'navigation') do
      capture(&block)      
    end
  end  

  def icon_bar
    content_tag(:span, nil, class: :'icon-bar')
  end  

  def hamburger
    (icon_bar * 3).html_safe
  end
end
