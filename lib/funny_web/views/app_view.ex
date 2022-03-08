defmodule FunnyWeb.AppView do
  use FunnyWeb, :view

  def comment_svg do
    ~E"""
    <?xml version="1.0" encoding="iso-8859-1"?>
    <svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
    color="#6c757d!important" style="fill: #6c757d!important" width="16px" height="16px" viewBox="0 0 428.428 428.428" style="enable-background:new 0 0 428.428 428.428;"
    xml:space="preserve">
    <g>
    <path d="M145.978,96.146h163.125c-1.146-15.041-13.742-26.931-29.073-26.931H29.169C13.085,69.215,0,82.301,0,98.384v129.44
    c0,16.084,13.085,29.17,29.169,29.17h22.029v51.382c0,3.552,2.072,6.778,5.302,8.255c1.208,0.553,2.497,0.823,3.775,0.823
    c2.14,0,4.255-0.755,5.938-2.21l39.048-33.74c-1.338-4.141-2.069-8.551-2.069-13.131v-129.44
    C103.191,115.341,122.385,96.146,145.978,96.146z"/>
    <path d="M399.259,110.975h-250.86c-16.084,0-29.17,13.085-29.17,29.169v129.441c0,16.084,13.086,29.169,29.17,29.169h146.403
    l67.414,58.25c1.683,1.453,3.798,2.209,5.938,2.209c1.276,0,2.564-0.271,3.773-0.823c3.23-1.478,5.303-4.702,5.303-8.255v-51.38
    h22.028c16.084,0,29.169-13.085,29.169-29.169V140.145C428.428,124.061,415.343,110.975,399.259,110.975z M201.202,226.324
    c-12.785,0-23.15-10.365-23.15-23.15s10.365-23.149,23.15-23.149c12.785,0,23.149,10.365,23.149,23.149
    C224.352,215.96,213.987,226.324,201.202,226.324z M273.829,226.324c-12.785,0-23.149-10.365-23.149-23.15
    s10.365-23.149,23.149-23.149c12.785,0,23.148,10.365,23.148,23.149C296.979,215.96,286.614,226.324,273.829,226.324z
     M346.456,226.324c-12.785,0-23.15-10.365-23.15-23.15s10.365-23.149,23.15-23.149s23.147,10.365,23.147,23.149
    C369.604,215.96,359.24,226.324,346.456,226.324z"/>
    </g>
    </svg>

    """
  end
end
