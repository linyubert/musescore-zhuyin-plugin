import QtQuick 2.0
import MuseScore 3.0

MuseScore {
    menuPath: "Plugins.添加注音音名"
    description: "在音符下方自動標示注音符號 (ㄅㄆㄇ)"
    version: "1.0"

    onRun: {
        // 確保有打開樂譜
        if (!curScore) {
            console.log("沒有打開的樂譜");
            Qt.quit();
            return;
        }

        // 開始一個可以 Undo (復原) 的動作
        curScore.startCmd();

        // 建立游標來走訪音符
        var cursor = curScore.newCursor();
        cursor.rewind(1); // 嘗試從使用者的「選取範圍」開始
        
        // 如果沒有選取範圍，就從樂譜的最開頭開始
        if (!cursor.segment) {
            cursor.rewind(0); 
        }

        // 建立音高 (Pitch Class) 到注音的對應表 (0=C, 1=C#, 2=D...)
        var zhuyinMap = {
            0: "ㄉ",
            1: "#ㄉ",
            2: "ㄖ",
            3: "#ㄖ",
            4: "ㄇ",
            5: "ㄈ",
            6: "#ㄈ",
            7: "ㄙ",
            8: "#ㄙ",
            9: "ㄌ",
            10: "bㄒ", // 降記號通常以 Bb 呈現
            11: "ㄒ"
        };

        // 開始走訪樂譜中的每一個節拍
        while (cursor.segment) {
            var element = cursor.element;
            
            // 檢查該位置是否有音符 (和弦)
            if (element && element.type === Element.CHORD) {
                var notes = element.notes;
                
                if (notes.length > 0) {
                    // 取出該和弦的最高音（或單音）
                    var topNote = notes[0]; 
                    
                    // 計算音高類別 (除以 12 的餘數：C=0, D=2...)
                    var pitchClass = topNote.pitch % 12;
                    var zhuyin = zhuyinMap[pitchClass];

                    // 如果找得到對應的注音，就把它加到譜上
                    if (zhuyin) {
                        var text = newElement(Element.STAFF_TEXT);
                        text.text = zhuyin;
                        // 設定文字位置在五線譜下方
                        text.placement = Placement.BELOW; 
                        
                        cursor.add(text);
                    }
                }
            }
            cursor.next(); // 往下一個音符前進
        }

        curScore.endCmd();
        Qt.quit();
    }
}