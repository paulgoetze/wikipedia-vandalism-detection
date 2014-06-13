module Wikipedia
  module VandalismDetection
    module WordLists

      MARKUP =
          [
              :'\{\{', :'\[\[', :infobox, :category, :defaultsort, :'<ref>', :cite, :'__toc__', :'__forcetoc__',
              :defaultsort, :reflist
          ]
    end
  end
end