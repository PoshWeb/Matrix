describe Matrix {    
    it 'Transforms' {
        $transformed = [Numerics.Vector2]::new(1,1) |
            scale 2 1
        $transformed.X | Should -be 2
            

        $transformed = [Numerics.Vector2]::new(1,1) |
            scale 1 2
        $transformed.Y | Should -be 2
    }

    context 2d {
        it 'Can Scale' {
            [Numerics.Vector2]::new(1,1) |
                scale 2 1 | 
                Select-Object -ExpandProperty X |
                Should -Be 2
        }

        it 'Can Translate' {
            $translated = [Numerics.Vector2]::new(1,1) |
                translate 1 2

            $translated.X | Should -Be 2
            $translated.Y | Should -Be 3

        }
        
        it 'Can skew' {
            $skewed = [Numerics.Vector2]::new(1,1) |
                skew 45deg 0
            $skewed.X | Should -Be 2
            $skewed.Y | Should -Be 1
        }

        it 'Can rotate' {
            $rotated = [Numerics.Vector2]::new(1,1) |
                rotate 90deg
             
            $rotated.X | Should -Be -1
            $rotated.Y | Should -Be 1
        }
    }

    context 3d {
        it 'Can Translate' {
            $translated = [Numerics.Vector3]::new(1,1,1) |
                translate3d 1 2 3

            $translated.X | Should -Be 2
            $translated.Y | Should -Be 3
            $translated.Z | Should -Be 4
        }

        it 'Can Scale' {
            $scaled = [Numerics.Vector3]::new(1,1,1) |
                scale3d 1 2 3

            $scaled.X | Should -Be 1
            $scaled.Y | Should -Be 2
            $scaled.Z | Should -Be 3
        }

        it 'Can Rotate' {
            $rotated = [Numerics.Vector3]::new(1,1,1) |
                rotate 90deg

            $rotated.X | Should -Be -1
            $rotated.Y | Should -Be 1
            $rotated.Z | Should -Be 1            
        }
        

        it 'Can Rotated3d' {
            (Rotate3d 1 1 1 30deg).CSS |
                Should -Be 'matrix3d(0.9106836, -0.2440169, 0.3333333, 0, 0.3333333, 0.9106836, -0.2440169, 0, -0.2440169, 0.3333333, 0.9106836, 0, 0, 0, 0, 1)'
        }

    }


}
