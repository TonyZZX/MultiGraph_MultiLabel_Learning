using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Touch.Models
{
    class Label
    {
        public static readonly string[] CATEGORY = { "building", "grass", "tree", "cow", "horse", "sheep", "sky", "mountain", "airplane", "water", "face", "car", "bicycle", "flower", "sign", "bird", "book", "chair", "road", "cat", "dog", "body", "boat" };

        public int Num { get; set; }
        public string Name { get => CATEGORY[Num]; }

        public Label(int num)
        {
            Num = num;
        }

        public static List<List<Label>> FromJson(string json)
        {
            var json_result = JsonConvert.DeserializeObject<List<List<int>>>(json);
            var result = json_result.ConvertAll(delegate (List<int> int_list)
            {
                var label_list = int_list.ConvertAll(delegate (int num)
                {
                    return new Label(num);
                });
                return label_list;
            });
            return result;
        }
    }
}
