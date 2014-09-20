﻿#region

using AutoMapper;

#endregion

namespace MyPractise.Entities.AutoMapper.Formatters.Abstract
{
    public abstract class ValueFormatter<T> : IValueFormatter
    {
        public string FormatValue(ResolutionContext context)
        {
            if (context.SourceValue == null)
            {
                return null;
            }
            if (!(context.SourceValue is T))
            {
                object value = context.SourceValue;

                return value == null ? string.Empty : value.ToString();
            }
            return FormatValueCore((T)context.SourceValue);
        }

        protected abstract string FormatValueCore(T value);
    }
}