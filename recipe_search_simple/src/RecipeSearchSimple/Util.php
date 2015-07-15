<?php

namespace RecipeSearchSimple;

class Util {
    public static function recipeTitleToId($recipeTitle)
    {
        return preg_replace('/[^\w]+/', '-', strtolower($recipeTitle));
    }
}
