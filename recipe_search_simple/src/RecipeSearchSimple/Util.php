<?php

namespace RecipeSearchSimple;

class Util {
    public static function recipeNameToId($recipeName)
    {
        return preg_replace('/[^\w]+/', '-', strtolower($recipeName));
    }
}
