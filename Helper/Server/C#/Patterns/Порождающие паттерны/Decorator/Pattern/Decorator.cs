using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Decorator.Pattern
{
    public abstract class Decorator : Button
    {
        protected Button button;

        public void SetButton(Button button)
        {
            this.button = button;
        }

        public override void Click()
        {
            if (this.button != null)
            {
                button.Click();
            }
        }

        public virtual void Test()
        {
            button.Click();
        }
    }
}
