//
//  generate.m
//  voronoi-gen
//
//  Created by Amit Shah on 2017-06-13.
//  Copyright © 2017 Amit Shah. All rights reserved.
//

#import "generate.h"
#import "voro++.hh"

struct vert
{
    float x,y,z;
};

extern "C" double rnd(){
    return double(rand())/RAND_MAX;
}

extern "C" int EXPORT_API val( ) {
    return 2;
}

extern "C" EXPORT_API int ReleaseMemory(void* pArray)
{
    delete[] pArray;
    return 0;
}

//Below is the correct method, the vector class was doing something bizarre with the .data attribute
extern "C" void EXPORT_API VoronoiCells(vert * verts, int vsize, float ** result, int * rsize){
    
    std::vector<float> vertices = std::vector<float>();
    for(int v = 0; v< vsize; v++){
        vertices.push_back((float)(1.0 * v));
    }
    
    float * arr=new float[5];
    arr[0]=1.2;
    arr[1]=2.12837;
    arr[2]=3.12837;
    arr[3]=4.12837;
    arr[4]=5.12837;
    //*result = arr;
    //*rsize = 5;
    float * r = new float[vertices.size()];
    std::copy(vertices.begin(), vertices.end(), r);
    *result = r;
    *rsize = (int)vertices.size();
    
}

//TODO: add gnuplot file generate to check the output is fine
//Below is the correct method, the vector class was doing something bizarre with the .data attribute
extern "C" void EXPORT_API GenerateVoronoiCells(vert * randomVerts, int vsize, float ** result, int * rsize){
    FILE *fp;
    fp = fopen("/Users/amitshah/unity/court-smash/Assets/face.test","w");

    int i;
    double x,y,z;
    int n_x=6,n_y=6,n_z=6;
    double x_min=-2,x_max=2;
    double y_min=-1,y_max=1;
    double z_min=-1,z_max=1;
    double cvol=(x_max-x_min)*(y_max-y_min)*(z_max-z_min);
    
    // Create a container with the geometry given above, and make it
    // non-periodic in each of the three coordinates. Allocate space for
    // eight particles within each computational block
    voro::container con(x_min,x_max,y_min,y_max,z_min,z_max,n_x,n_y,n_z,
                        false,false,false,8);
    
    // Randomly add particles into the container
    for(i=0;i<vsize;i++) {
        con.put(i,randomVerts[i].x,randomVerts[i].y,randomVerts[i].z);
    }
    
    // Sum up the volumes, and check that this matches the container volume
    double vvol=con.sum_cell_volumes();
    voro::voronoicell vc;
    voro::c_loop_all vl(con);
    
    std::vector<float> vertices = std::vector<float>();
    
    std::vector<int> v;
    if(vl.start()) do{
        con.compute_cell(vc,vl);
        vc.face_vertices(v);
        
        //find the displacement vector
        double * pp = con.p[vl.ijk]+con.ps*vl.q;
        printf("\n//ALL VC POINTS:\n");
        
        fprintf(fp,"\nvc.Add(new List<Vector3>(){\n");
        
        printf("\nvc.Add(new List<Vector3>(){\n");
        double *ptsp=vc.pts;
        
        
        for(int i=0;i<3*vc.p;i+=3) {
            fprintf(fp,"new Vector3(%gf,%gf,%gf),\n",*pp+*(ptsp)*0.5,
                    pp[1]+*(ptsp+1)*0.5,
                    pp[2]+ *(ptsp+2)*0.5);
            printf("new Vector3(%gf,%gf,%gf),\n",*pp+*(ptsp)*0.5,
                   pp[1]+*(ptsp+1)*0.5,
                   pp[2]+ *(ptsp+2)*0.5);
            vertices.push_back((float)(*pp+*(ptsp++)*0.5));
            vertices.push_back((float)(pp[1]+*(ptsp++)*0.5));
            vertices.push_back((float)(pp[2]+ *(ptsp++)*0.5));
            
        }
        vertices.push_back(-9999.0f);
        vertices.push_back(-9999.0f);
        vertices.push_back(-9999.0f);
        fprintf(fp, "\n });\n");
        printf("\n });\n");
        
    }while(vl.inc());
    fclose(fp);
    
    float * r = new float[vertices.size()];
    std::copy(vertices.begin(), vertices.end(), r);
    *result = r;
    *rsize = (int)vertices.size();
}

extern "C" void EXPORT_API _VoronoiCells(vert * verts, int vsize, double ** result, int * rsize){
    FILE *fp;
    fp = fopen("/Users/amitshah/unity/court-smash/Assets/face.test","w");
    for(int v = 0; v< vsize; v++){
        fprintf(fp,"%gf,%gf,%gf",verts[v].x,verts[v].y,verts[v].z);
        verts[v].y = verts[v].y + v;
    }
    int i;
    double x,y,z;
    int n_x=6,n_y=6,n_z=6;
    double x_min=-2,x_max=2;
    double y_min=-1,y_max=1;
    double z_min=-1,z_max=1;
    double cvol=(x_max-x_min)*(y_max-y_min)*(z_max-z_min);
    
    // Create a container with the geometry given above, and make it
    // non-periodic in each of the three coordinates. Allocate space for
    // eight particles within each computational block
    voro::container con(x_min,x_max,y_min,y_max,z_min,z_max,n_x,n_y,n_z,
                        false,false,false,8);
    
    // Randomly add particles into the container
    for(i=0;i<20;i++) {
        x=x_min+rnd()*(x_max-x_min);
        y=y_min+rnd()*(y_max-y_min);
        z=z_min+rnd()*(z_max-z_min);
        con.put(i,x,y,z);
    }
    
    // Sum up the volumes, and check that this matches the container volume
    double vvol=con.sum_cell_volumes();
    
    // Output the particle positions in gnuplot format
    //con.draw_particles("random_points_p.gnu");
    
    // Output the Voronoi cells in gnuplot format
    voro::voronoicell vc;
    voro::c_loop_all vl(con);
    //refer to interface example :)
    
    std::vector<double> vertices = std::vector<double>();
    
    std::vector<int> v;
    if(vl.start()) do{
        con.compute_cell(vc,vl);
        vc.face_vertices(v);
        //find the displacement vector
        double * pp = con.p[vl.ijk]+con.ps*vl.q;
        printf("\n//ALL VC POINTS:\n");
        
        fprintf(fp,"\nvc.Add(new List<Vector3>(){\n");
        
        printf("\nvc.Add(new List<Vector3>(){\n");
        double *ptsp=vc.pts;
        
        
        for(int i=0;i<3*vc.p;i+=3) {
            fprintf(fp,"new Vector3(%gf,%gf,%gf),\n",*pp+*(ptsp)*0.5,
                    pp[1]+*(ptsp+1)*0.5,
                    pp[2]+ *(ptsp+2)*0.5);
            printf("new Vector3(%gf,%gf,%gf),\n",*pp+*(ptsp)*0.5,
                   pp[1]+*(ptsp+1)*0.5,
                   pp[2]+ *(ptsp+2)*0.5);
            vertices.push_back(*pp+*(ptsp++)*0.5);
            vertices.push_back(pp[1]+*(ptsp++)*0.5);
            vertices.push_back(pp[2]+ *(ptsp++)*0.5);
            
        }
        vertices.push_back(-999.0);
        fprintf(fp, "\n });\n");
        printf("\n });\n");
        
    }while(vl.inc());
    fclose(fp);
    
    //con.print_custom("ID=%i, pos=(%x,%y,%z), vertices=%w, edges=%g, faces=%s, face_verts=%t","/Users/amitshah/unity/court-smash/Assets/face.test");
    *result = vertices.data();
    *rsize = vertices.size();
    
}

extern "C" char* EXPORT_API GenerateCells( double ** result, int * resultCount, int **cellResult, int * cellResultCount ) {
    int i;
    double x,y,z;
    int n_x=6,n_y=6,n_z=6;
    double x_min=-2,x_max=2;
    double y_min=-1,y_max=1;
    double z_min=-1,z_max=1;
    double cvol=(x_max-x_min)*(y_max-y_min)*(z_max-z_min);
    
    // Create a container with the geometry given above, and make it
    // non-periodic in each of the three coordinates. Allocate space for
    // eight particles within each computational block
    voro::container con(x_min,x_max,y_min,y_max,z_min,z_max,n_x,n_y,n_z,
                        false,false,false,8);
    
    // Randomly add particles into the container
    for(i=0;i<100;i++) {
        x=x_min+rnd()*(x_max-x_min);
        y=y_min+rnd()*(y_max-y_min);
        z=z_min+rnd()*(z_max-z_min);
        con.put(i,x,y,z);
    }
    
    // Sum up the volumes, and check that this matches the container volume
    double vvol=con.sum_cell_volumes();
    
    printf("Container volume : %g\n"
           "Voronoi volume   : %g\n"
           "Difference       : %g\n",cvol,vvol,vvol-cvol);
    
    // Output the particle positions in gnuplot format
    //con.draw_particles("random_points_p.gnu");
    
    // Output the Voronoi cells in gnuplot format
    voro::voronoicell vc;
    voro::c_loop_all vl(con);
    //refer to interface example :)
    std::vector<double> vertices = std::vector<double>();
    std::vector<int> cells = std::vector<int>();
    
    std::vector<int> v;
    
    if(vl.start()) do{
        con.compute_cell(vc,vl);
        vc.face_vertices(v);
        //find the displacement vector
        double * pp = con.p[vl.ijk]+con.ps*vl.q;
        printf("\nSIZE:%lu\n", v.size());
        
        cells.push_back(v.size());
        //Amit: Refer to Common.cc line 62:
        //  void voro_print_face_vertices(std::vector<int> &v,FILE *fp) {
        //TODO:Validate this method
        int j,k=0,l,counter=0;
        if(v.size()>0) {
            
            //container.hh line 604
            //printf("%d",p[vl.ijk]+con.ps*vl.q);
                        l=v[k++];
            if(l<=1) {
                if(l==1){
                    
                    printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                    
                    vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                    counter++;
                    k++;
                }
                else{
                    cells.push_back(k);
                    printf("()");
                }
            } else {
                j=k+l;
                printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                counter++;
                k++;
                
                while(k<j){
                    printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                    counter++;
                    k++;
                }
                cells.push_back(k);
            }
            
            while((unsigned int) k<v.size()) {
                
                l=v[k++];
                if(l<=1) {
                    if(l==1){
                        printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                        counter++;
                        k++;
                    }
                    else{
                        cells.push_back(k);
                    }
                } else {
                    j=k+l;
                    printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                    vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                    counter++;
                    k++;
                    
                    while(k<j){
                        printf("new Vector3(%gf,%gf,%gf),\r\n",*pp+vc.pts[v[k]-1]*0.5,pp[1]+vc.pts[v[k]]*0.5,pp[2]+vc.pts[v[k]+1]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]-1]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]]*0.5);
                        vertices.push_back(*pp+vc.pts[v[k]+1]*0.5);
                        counter++;
                        k++;
                    }
                    cells.push_back(k);
                }
            }
        }
        //}
        
    }while(vl.inc());
    
    
    printf("done");
    //con.draw_cells_gnuplot("random_points_v.gnu");
    //con.print_custom("order=%o, vertices=%p","vertices.test");
    
    //con.print_custom("ID=%i, pos=(%x,%y,%z), vertices=%w, edges=%g, faces=%s, face_verts=%t","face.test");
    printf("\n%lu,%lu\n", vertices.size(), cells.size());
    //    (*cellSize) = cells.size();
    //    (*verticeSize) = vertices.size();
    //    (*cellsPtr) = new int[cells.size()];
    //    (*verticesPtr) = new double[vertices.size()];
    //    std::copy(cells.begin(), cells.end(), (*cellsPtr));
    //    std::copy(vertices.begin(), vertices.end(), (*verticesPtr));
    *result = vertices.data();
    *resultCount = vertices.size();
    *cellResult = cells.data();
    *cellResultCount = cells.size();
    return "good";
}
